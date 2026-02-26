{ config, ... }:

let

  name = "birkhoff";
  email = "git@birkhoff.me";
  key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0762tms0QT6kCQ7tTgoOdm+ry29ImKgDk09hXurEfM";

in
{
  home.file.".config/git/allowed_signers".text = "${email} namespaces=\"git\" ${key}";

  programs.git = {
    enable = true;

    lfs.enable = true;

    settings = {
      user = {
        name = "${name}";
        email = "${email}";
        signingkey = "${key}";
      };

      pager = {
        show = "delta";
        diff = "delta";
        log = "emojify";
      };

      core = {
        preloadindex = "yes";
        editor = "hx";
      };

      credential = {
        helper = "osxkeychain";
      };

      merge = {
        conflictstyle = "zdiff3";
      };

      # reuse recorded resolution
      # @see https://git-scm.com/book/en/v2/Git-Tools-Rerere
      rerere = {
        enable = true;
      };

      format = {
        pretty = "oneline";
      };

      gpg = {
        format = "ssh";

        ssh = {
          program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
          allowedSignersFile = "${config.home.homeDirectory}/.config/git/allowed_signers";
        };
      };

      commit = {
        gpgsign = true;
      };

      pull = {
        rebase = "true";
      };

      push = {
        default = "simple";
        autoSetupRemote = "true";
      };

      http = {
        postBuffer = "52428800";
      };

      url = {
        "git@github.com:" = {
          insteadOf = "https://github.com/";
        };
      };

      color = {
        ui = "true";
      };

      alias = {
        # add
        a = "add"; # add
        chunkyadd = "add --patch"; # stage commits chunk by chunk

        # via http://blog.apiaxle.com/post/handy-git-tips-to-stop-you-getting-fired/
        snapshot = "!git stash save \"snapshot: $(date)\" && git stash apply \"stash@{0}\"";
        snapshots = "!git stash list --grep snapshot";

        # via http://stackoverflow.com/questions/5188320/how-can-i-get-a-list-of-git-branches-ordered-by-most-recent-commit
        recent-branches = "!git for-each-ref --count=15 --sort=-committerdate refs/heads/ --format='%(refname:short)'";

        # branch
        b = "branch -v"; # branch (verbose)

        # commit
        c = "commit -m"; # commit with message
        ca = "commit -am"; # commit all with message
        ci = "commit"; # commit
        amend = "commit --amend"; # ammend your last commit
        ammend = "commit --amend"; # ammend your last commit

        # checkout
        co = "checkout"; # checkout
        nb = "checkout -b"; # create and switch to a new branch (mnemonic: "git new branch branchname...")

        # cherry-pick
        cp = "cherry-pick -x"; # grab a change from a branch

        # diff
        d = "diff"; # diff unstaged changes
        dc = "diff --cached"; # diff staged changes
        last = "diff HEAD^"; # diff last committed change

        # log
        l = "log --graph --date=short";
        changes = "log --pretty=format:\"%h %cr %cn %Cgreen%s%Creset\" --name-status";
        short = "log --pretty=format:\"%h %cr %cn %Cgreen%s%Creset\"";
        simple = "log --pretty=format:\" * %s\"";
        shortnocolor = "log --pretty=format:\"%h %cr %cn %s\"";

        # pull
        pl = "pull"; # pull

        # push
        ps = "push"; # push

        # rebase
        rc = "rebase --continue"; # continue rebase
        rs = "rebase --skip"; # skip rebase

        # remote
        r = "remote -v"; # show remotes (verbose)

        # reset
        unstage = "reset HEAD"; # remove files from index (tracking)
        uncommit = "reset --soft HEAD^"; # go back before last commit, with files in uncommitted state
        filelog = "log -u"; # show changes to a file
        mt = "mergetool"; # fire up the merge tool

        # stash
        ss = "stash"; # stash changes
        sl = "stash list"; # list stashes
        sa = "stash apply"; # apply stash (restore changes)
        sd = "stash drop"; # drop stashes (destory changes)

        # status
        s = "status"; # status
        st = "status"; # status
        stat = "status"; # status

        # tag
        t = "tag -n"; # show tags with <n> lines of each tag message

        # svn helpers
        svnr = "svn rebase";
        svnd = "svn dcommit";
        svnl = "svn log --oneline --show-commit";
      };
    };
  };
}
