echo "Begin Hardening Process"
export DESIGN_CONFIG=designs/180_180/bottom_die/config.mk
make
echo "Finish harden the bottom die"
sleep 2
export DESIGN_CONFIG=designs/180_180/top_die/config.mk
make
echo "ALL Finished"
