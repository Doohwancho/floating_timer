# A. what

![](images/2024-05-20-19-41-12.png)

Minimal Floating Timer

만들게 된 계기: 아니 어떻게 타이머 앱이 2만 2천원?

# B. feature

1. timer(decremental, incremental)
2. floating
3. keyboard shortcuts
4. layout: 1. goal / 2. today's accumulated time / 3. total accumulate time
5. calendar


# C. shortcut

```
1. spacebar: start/pause decremental timer
2. command + s: start/stop increment timer
3. 숫자키: 시간 설정(in minute)
4. command + 1: minimal timer mode
5. command + 2: transparent timer mode
6. command + 3: calendar mode
7. i: insert mode(set goal on minimal_timer)
8. esc, enter: exit insert mode
9. h,l to switch months in calendar
```

# D. TODO

1. insert mode에서 capslock 눌렀을 때 부숴진 ascii code 입력되는 문제 해결하기
2. minimal_timer에 goal 추가 시 한글도 입력되는 기능 추가하기
