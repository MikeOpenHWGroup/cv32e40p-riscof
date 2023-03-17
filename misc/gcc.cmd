riscv32-unknown-elf-gcc               \
                        -march=rv32ic \
                        -static \
                        -mcmodel=medany \
                        -fvisibility=hidden \
                        -nostdlib \
                        -nostartfiles \
                        -g \
                        -T /home/mike/GitHubRepos/MikeOpenHWGroup/cv32e40p-riscof/add_e40p/plugin-cv32e40p/env/link.ld \
                        -I /home/mike/GitHubRepos/MikeOpenHWGroup/cv32e40p-riscof/add_e40p/plugin-cv32e40p/env/ \
                        -I /home/mike/GitHubRepos/MikeOpenHWGroup/cv32e40p-riscof/add_e40p/plugin-cv32e40p/env \
                        /home/mike/GitHubRepos/MikeOpenHWGroup/cv32e40p-riscof/add_e40p/riscv-arch-test/riscv-test-suite/rv32i_m/C/src/cadd-01.S \
                        -o main.elf \
                        -DTEST_CASE_1=True \
                        -DXLEN=32 \
                        -mabi=ilp32
