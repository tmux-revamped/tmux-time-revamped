Source common.tape
Output hero.gif
Hide
Type "tmux -L revamped-screens attach -t demo"
Enter
Sleep 1.5s
Show
Sleep 1.5s
Sleep 2s
Screenshot status.png
Sleep 1s
Hide
Ctrl+]
Sleep 300ms
Type@5ms "prefix M-t, h"
Enter
Show
Ctrl+B
Escape
Type@1ms "t"
Sleep 1s
Screenshot menu.png
Sleep 800ms
Type@1ms "h"
Sleep 2s
Screenshot twelve.png
Sleep 800ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "prefix M-t, h"
Enter
Show
Ctrl+B
Escape
Type@1ms "t"
Sleep 1s
Type@1ms "h"
Sleep 2s
Hide
Ctrl+]
Sleep 300ms
Type@5ms "prefix M-t, c, q"
Enter
Show
Ctrl+B
Escape
Type@1ms "t"
Sleep 1s
Type@1ms "c"
Sleep 1500ms
Screenshot calendar.png
Sleep 800ms
Type@1ms "q"
Sleep 1s
Hide
Ctrl+]
Sleep 300ms
Type@5ms "prefix M-t, i"
Enter
Show
Ctrl+B
Escape
Type@1ms "t"
Sleep 1s
Type@1ms "i"
Sleep 1s
Screenshot copy.png
Sleep 800ms
Hide
Ctrl+]
Sleep 300ms
Type@5ms "prefix u, q"
Enter
Show
Ctrl+B
Type@1ms "u"
Sleep 1500ms
Screenshot calendar-key.png
Sleep 800ms
Type@1ms "q"
Sleep 1s
Hide
Ctrl+]
Sleep 300ms
Type@5ms "prefix y"
Enter
Show
Ctrl+B
Type@1ms "y"
Sleep 1s
Screenshot copy-key.png
Sleep 800ms
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g status-right '#{time_date} #{time_clock} #{time_elapsed} #{time_zones}'"
Enter
Show
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "run-shell '/Users/Shared/demo/tmux-time-revamped/bin/time-revamped apply'"
Enter
Show
Sleep 1s
Hide
Ctrl+]
Sleep 300ms
Type@5ms "prefix j"
Enter
Show
Ctrl+B
Type@1ms "j"
Sleep 1s
Screenshot mark-key.png
Sleep 800ms
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "run-shell 'printf 1792165500 >/Users/Shared/demo/now'"
Enter
Show
Sleep 2500ms
Screenshot mark.png
Sleep 800ms
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "run-shell 'printf 1792161000 >/Users/Shared/demo/now'"
Enter
Show
Hide
Type "clear"
Enter
Sleep 600ms
Show
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux set -g @time_revamped_render options"
Enter
Show
Sleep 800ms
Type "tmux set -g @time_revamped_render options"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1s
Hide
Ctrl+B
Type ":"
Sleep 300ms
Type@1ms "set -g status-right '#{time_date} #{time_clock}  #{time_zones}'"
Enter
Show
Hide
Ctrl+]
Sleep 300ms
Type@5ms "time-revamped apply"
Enter
Show
Sleep 800ms
Type "time-revamped apply"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3s
Hide
Ctrl+]
Sleep 300ms
Type@5ms "tmux show -gv status-right | cut -c1-100"
Enter
Show
Sleep 800ms
Type "tmux show -gv status-right | cut -c1-100"
Hide
Ctrl+]
Sleep 300ms
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3s
Sleep 1s
Screenshot options.png
Sleep 800ms
Sleep 1500ms
