echo "NOADJ"
gawk -v node_count=200 -f lpf.awk NOADJ/log_lpf_n200.txt
gawk -v node_count=400 -f lpf.awk NOADJ/log_lpf_n400.txt
gawk -v node_count=600 -f lpf.awk NOADJ/log_lpf_n600.txt
gawk -v node_count=800 -f lpf.awk NOADJ/log_lpf_n800.txt
gawk -v node_count=1000 -f lpf.awk NOADJ/log_lpf_n1000.txt
gawk -v node_count=1200 -f lpf.awk NOADJ/log_lpf_n1200.txt

echo "ADJ-HALF"
gawk -v node_count=200 -f lpf.awk HALFADJ/log_lpf_n200.txt
gawk -v node_count=400 -f lpf.awk HALFADJ/log_lpf_n400.txt
gawk -v node_count=600 -f lpf.awk HALFADJ/log_lpf_n600.txt
gawk -v node_count=800 -f lpf.awk HALFADJ/log_lpf_n800.txt
gawk -v node_count=1000 -f lpf.awk HALFADJ/log_lpf_n1000.txt
gawk -v node_count=1200 -f lpf.awk HALFADJ/log_lpf_n1200.txt
