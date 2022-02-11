# hwatch
* simple watcher by inotify.

## build
```
cabal build
```

## install
```
cabal install
# update path env with rehash like
which hwatch
```

## run
```
hwatch ${dirs comma sepalated without space} ${shell command}
# ex.
hwatch app,src cabal test
```
