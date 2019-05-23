if exist minizip (
  cd minizip
  git reset --hard
  git clean -fd
  git pull
) else (
  git clone https://github.com/nmoinvaz/minizip.git
)

pause