{ pkgs }:
{
  # Need this to make sure notify won't send bad characters to telegram bot
  # Python because sed was proving difficult
  tgEscape = pkgs.writeShellApplication {
    name = "tg-escape";
    runtimeInputs = [ pkgs.python314 ];
    text = ''
      python3 -c '
      import sys
      s = sys.stdin.read()
      esc = r"\_*[]()~`>#+-=|{}.!\\"
      out = []
      for ch in s:
          out.append("\\" + ch if ch in esc else ch)
      sys.stdout.write("".join(out))
      '
    '';
  };
}
