python3 -c "print('-'*30)" > perf/andromeda.perf
sudo perf stat -e L1-dcache-loads -e L1-dcache-load-misses -e LLC-loads -e LLC-load-misses ./kmeans inp/andromeda_tiled_rgb.bmp andr 4 2>> perf/andromeda.perf 1> /dev/null
python3 -c "print('-'*30)" >> perf/andromeda.perf
