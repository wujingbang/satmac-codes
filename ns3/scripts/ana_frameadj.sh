echo "ADJ_ALL T0.3E0.5"
gawk -v node_count=200 -f lpf.awk SATMAC/T0.3E0.5/log_lpf_n200.txt
gawk -v node_count=400 -f lpf.awk SATMAC/T0.3E0.5/log_lpf_n400.txt
gawk -v node_count=600 -f lpf.awk SATMAC/T0.3E0.5/log_lpf_n600.txt
gawk -v node_count=800 -f lpf.awk SATMAC/T0.3E0.5/log_lpf_n800.txt
gawk -v node_count=1000 -f lpf.awk SATMAC/T0.3E0.5/log_lpf_n1000.txt
gawk -v node_count=1200 -f lpf.awk SATMAC/T0.3E0.5/log_lpf_n1200.txt

echo "ADJ_ALL T0.4E0.5"
gawk -v node_count=200 -f lpf.awk SATMAC/T0.4E0.5/log_lpf_n200.txt
gawk -v node_count=400 -f lpf.awk SATMAC/T0.4E0.5/log_lpf_n400.txt
gawk -v node_count=600 -f lpf.awk SATMAC/T0.4E0.5/log_lpf_n600.txt
gawk -v node_count=800 -f lpf.awk SATMAC/T0.4E0.5/log_lpf_n800.txt
gawk -v node_count=1000 -f lpf.awk SATMAC/T0.4E0.5/log_lpf_n1000.txt
gawk -v node_count=1200 -f lpf.awk SATMAC/T0.4E0.5/log_lpf_n1200.txt

echo "ADJ_ALL T0.4E0.6"
gawk -v node_count=200 -f lpf.awk SATMAC/T0.4E0.6/log_lpf_n200.txt
gawk -v node_count=400 -f lpf.awk SATMAC/T0.4E0.6/log_lpf_n400.txt
gawk -v node_count=600 -f lpf.awk SATMAC/T0.4E0.6/log_lpf_n600.txt
gawk -v node_count=800 -f lpf.awk SATMAC/T0.4E0.6/log_lpf_n800.txt
gawk -v node_count=1000 -f lpf.awk SATMAC/T0.4E0.6/log_lpf_n1000.txt
gawk -v node_count=1200 -f lpf.awk SATMAC/T0.4E0.6/log_lpf_n1200.txt

echo "ADJ_ALL T0.5E0.6"
gawk -v node_count=200 -f lpf.awk SATMAC/T0.5E0.6/log_lpf_n200.txt
gawk -v node_count=400 -f lpf.awk SATMAC/T0.5E0.6/log_lpf_n400.txt
gawk -v node_count=600 -f lpf.awk SATMAC/T0.5E0.6/log_lpf_n600.txt
gawk -v node_count=800 -f lpf.awk SATMAC/T0.5E0.6/log_lpf_n800.txt
gawk -v node_count=1000 -f lpf.awk SATMAC/T0.5E0.6/log_lpf_n1000.txt
gawk -v node_count=1200 -f lpf.awk SATMAC/T0.6E0.6/log_lpf_n1200.txt
