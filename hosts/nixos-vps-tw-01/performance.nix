{ lib, ... }:

let
  # Whether this machine has less than 2 GB of RAM.
  # When true, VM parameters are tuned more conservatively to avoid OOM.
  hasFewRam = false; # this host has 2 GB RAM (not < 2 GB)

  # Network characteristics used to size TCP socket buffers.
  bandwidth = 2000; # uplink / downlink capacity in Mbit/s
  worst_rtt = 250; # worst-case round-trip time in milliseconds

  # Bandwidth-delay product in bytes:
  #   BDP = bandwidth (Mbit/s) × 1 000 000 / 8 (bytes/bit) × RTT (ms)
  # Integer-safe form: multiply by RTT before dividing by 1000 to avoid
  # losing precision when Nix truncates integer division.
  bdp = bandwidth * 1000 / 8 * worst_rtt; # bytes

  # Socket buffer size = BDP × 4.
  # ×2 because Linux uses only half the buffer for actual data (the other
  # half is reserved for kernel bookkeeping), and ×2 again for BBR, which
  # needs extra headroom to probe bandwidth under moderate packet loss.
  bufferSize = bdp * 4; # bytes
in
{
  boot.kernelModules = [ "tcp_bbr" ];

  boot.kernel.sysctl = {
    # ===== Network optimisation =====

    # Allow reuse of TIME_WAIT sockets; improves throughput under high concurrency
    "net.ipv4.tcp_tw_reuse" = 1;

    # Maximise the ephemeral port range available for outgoing connections
    "net.ipv4.ip_local_port_range" = "1024 65535";

    # Listen backlog: how many pending connections the kernel queues
    "net.core.somaxconn" = 4096;
    "net.ipv4.tcp_max_syn_backlog" = 8192;

    # NIC receive queue depth; prevents packet drops on high-bandwidth bursts
    "net.core.netdev_max_backlog" = 5000;

    # Do not throttle cwnd after an idle period (keeps throughput high for
    # long-lived but bursty connections such as proxy tunnels)
    "net.ipv4.tcp_slow_start_after_idle" = 0;

    # Probe for the path MTU; avoids fragmentation on links with lower MTU
    "net.ipv4.tcp_mtu_probing" = 1;

    # Cap unsent data in the socket send buffer; critical for upload throughput
    # on high-RTT links (avoids head-of-line bloat in the kernel buffer)
    "net.ipv4.tcp_notsent_lowat" = 16384;

    # How long a FIN_WAIT2 socket lives before the kernel reclaims it
    "net.ipv4.tcp_fin_timeout" = 15;

    # Maximum number of TIME_WAIT sockets before the kernel starts recycling them
    "net.ipv4.tcp_max_tw_buckets" = 5000;

    # TCP Fast Open on both client and server sides; saves one RTT on reconnects
    "net.ipv4.tcp_fastopen" = 3;

    # Keep-alive: start probing after 5 min idle, every 30 s, give up after 5 misses
    "net.ipv4.tcp_keepalive_time" = 300;
    "net.ipv4.tcp_keepalive_intvl" = 30;
    "net.ipv4.tcp_keepalive_probes" = 5;

    # Minimum UDP receive/send buffer (needed for QUIC / Hysteria transports)
    "net.ipv4.udp_rmem_min" = 8192;
    "net.ipv4.udp_wmem_min" = 8192;

    # SYN cookies protect against SYN-flood DoS attacks
    "net.ipv4.tcp_syncookies" = 1;

    # Enable BBR and fq
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";

    # ===== TCP socket buffer sizing (bandwidth-delay product) =====
    # tcp_rmem / tcp_wmem override the core defaults when SO_RCVBUF/SO_SNDBUF
    # are not set explicitly; setting both to the same value avoids ambiguity.
    # We leave net.ipv4.tcp_mem alone — the kernel already reserves ~9% of
    # system RAM for TCP by default, which is sufficient.
    "net.core.rmem_max" = bufferSize;
    "net.core.wmem_max" = bufferSize;
    "net.ipv4.tcp_rmem" = "4096 87380 ${toString bufferSize}";
    "net.ipv4.tcp_wmem" = "4096 87380 ${toString bufferSize}";

    # ===== Virtual-memory tuning =====
    # Values depend on how much RAM the machine has.

    # How aggressively the kernel swaps anonymous pages (lower = prefer RAM)
    "vm.swappiness" = if hasFewRam then 20 else 5;

    # Maximum % of dirty pages before the kernel blocks writers and flushes
    "vm.dirty_ratio" = if hasFewRam then 20 else 15;

    # % of dirty pages at which the background flush daemon wakes up
    "vm.dirty_background_ratio" = 5;

    # Allow over-committing virtual memory (common for proxy/server workloads)
    "vm.overcommit_memory" = 1;

    # Minimum free memory the kernel tries to keep (in kB)
    "vm.min_free_kbytes" = if hasFewRam then 32768 else 65536;

    # How aggressively the kernel reclaims dentries/inodes vs anonymous pages
    "vm.vfs_cache_pressure" = 50;

    # ===== CPU scheduler tuning =====

    # Disable automatic process grouping by session; reduces latency jitter for
    # network-bound workloads where all processes should compete equally
    "kernel.sched_autogroup_enabled" = 0;

    # Disable automatic NUMA page migration; this is a single-node VM
    "kernel.numa_balancing" = 0;
  };
}
