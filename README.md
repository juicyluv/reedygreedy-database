# ReedyGreedy Database

Database implementation of the [RreedyGreedy project](https://github.com/juicyluv/reedygreedy).

## Initialization and start

1. Generate database init file 
```make
make gen
```

2. Initialize database via generated init file
```bash 
make patch
```

Make sure that you have proper `pg_hba.conf` file.
You can change the settings as you like.