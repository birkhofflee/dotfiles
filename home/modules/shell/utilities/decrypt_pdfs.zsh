#!/usr/bin/env zsh

set -euo pipefail

# Decrypt all PDFs in the current directory using the given password.
# Usage: decrypt_pdfs <password>
if [ $# -ne 1 ]; then
  echo "Usage: decrypt_pdfs <password>"
  exit 1
fi

password="$1"

for file in *.pdf; do
  # Skip if it's not a regular file
  [ -f "$file" ] || continue

  # Check if it's encrypted
  if qpdf --check "$file" 2>&1 | grep -q "is not encrypted"; then
    echo "Already decrypted: $file"
  else
    echo "Decrypting: $file"
    tmp_file="tmp_decrypted.pdf"
    if qpdf --decrypt --password="$password" "$file" "$tmp_file"; then
      mv "$tmp_file" "$file"
      echo "Decrypted: $file"
    else
      echo "Failed to decrypt: $file"
      rm -f "$tmp_file"
    fi
  fi
done
