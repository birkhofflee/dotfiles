{
  editorconfig = {
    enable = true;

    settings = {
      "*" = {
        "charset" = "utf-8";
        "end_of_line" = "lf";
        "insert_final_newline" = "true";
        "indent_style" = "space";
      };

      "*.py" = {
        "indent_size" = 4;
      };

      "*.go" = {
        "indent_style" = "tab";
      };

      "*.{js,ts,jsx,cjs}" = {
        "indent_size" = 2;
      };

      "Makefile" = {
        "indent_style" = "tab";
      };
    };
  };
}
