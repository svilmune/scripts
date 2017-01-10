#!/bin/bash
#   Description: Simple script to get all sundiag outputs from all nodes and tar them ready for support under /tmp/
#                If you want to get the ILOM snapshot use parameter snapshot as first argument
#   Written by:  Simo Vilmunen 06-JAN-2017
#
#   How to use:  run as get_sundiag_from_all_nodes.sh           --to get normal sundiag from all nodes
#
#   Output: Will be written to /tmp/sundiag_output_<current_date> and tarball created under /tmp/
#
#   Version: 1.0 10/01/2017

export script_dir=/tmp/sundiag_output_$(date +%Y%m%d)
export script_log=/tmp/sundiag_output_$(date +%Y%m%d)/diagnostics_output_$(date +%Y%m%d).log

echo `date`": Getting sundiag scripts from all nodes" | tee -a "$script_log"

if [ -d "$script_dir" ]
then
echo `date`": /tmp/sundiag_output_$(date +%Y%m%d) exists" | tee -a "$script_log"
rm -rf /tmp/sundiag_output_$(date +%Y%m%d)/*
else
mkdir "/tmp/sundiag_output_$(date +%Y%m%d)"
echo `date`": Directory /tmp/sundiag_output_$(date +%Y%m%d_%H%M%S) created"  | tee -a "$script_log"
fi

touch "${script_log}"

#  Backup old sundiag files and remove them after zipped
echo `date`": Compressing old sundiag files and removing them" | tee -a "$script_log"
dcli -g /root/all_group -l root "zip -u /var/log/exadatatmp/previous_sundiag_outputs.zip /var/log/exadatatmp/sundiag*.tar.bz2" | tee -a "$script_log"
dcli -g /root/all_group -l root 'rm /var/log/exadatatmp/sundiag*.tar.bz2' | tee -a "$script_log"


#  Normal sundiag.sh execution

echo `date`": Running dcli sundiag.sh on all nodes" | tee -a "$script_log"
dcli -g /root/all_group -l root '/opt/oracle.SupportTools/sundiag.sh 2>/dev/null'   | tee -a "$script_log" >/dev/null

for H in `cat /root/all_group`; do  scp -p $H:/var/log/exadatatmp/sundiag*.tar.bz2 /tmp/sundiag_output_$(date +%Y%m%d) ; done  | tee -a "$script_log"

export file_name=exa_rack_sundiag_$(date +%Y%m%d_%H%M%S).tar.bz2

cd /tmp;tar -jcvf /tmp/${file_name} sundiag_output_$(date +%Y%m%d)/sundiag*.tar.bz2  | tee -a "$script_log"

echo `date`": Combined tar file of /tmp/sundiag_output_$(date +%Y%m%d) created as /tmp/${file_name}"  | tee -a "$script_log"

echo `date`":  You can review the logfile ${script_log} for errors. All done now. Have a great day."  | tee -a "$script_log"

exit
