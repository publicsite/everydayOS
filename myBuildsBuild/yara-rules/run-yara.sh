#!/bin/sh
if ! [ -d "$1" ]; then
echo "Argv1: The directory you wish to scan"
exit
fi

if [ -d /yara/yara-logs ]; then
	rm -rf /yara/yara-logs
fi

if [ -d /yara/yara-error-log ]; then
	rm -rf /yara/yara-error-log
fi

mkdir /yara/yara-logs
mkdir /yara/yara-error-log
find /yara/yara-rules-copied -maxdepth 1 -mindepth 1 -type d | while read line; do
	if [ "$(basename "${line}")" = "rules" ]; then
scan -Y -b domain -b contains_base64 -b IP -b Misc_Suspicious_Strings -b android_meterpreter -b url "${line}" -r "$1" 2>/yara/yara-error-log/$(basename ${line}).errorlog 1>/yara/yara-logs/$(basename ${line}).log &
	elif [ "$(basename "${line}")" = "yara" ]; then
scan -Y -b maldoc_indirect_function_call_3 -b maldoc_suspicious_strings -b maldoc_getEIP_method_1 -b embedded_macho -b maldoc_function_prolog_signature -b dbgdetect_files -b maldoc_structured_exception_handling "${line}" -r "$1" 2>/yara/yara-error-log/$(basename ${line}).errorlog 1>/yara/yara-logs/$(basename ${line}).log &
	elif [ "$(basename "${line}")" = "h3x2b" ]; then
scan -Y -b math_entropy_1 -b math_entropy_2 -b math_entropy_3 -b math_entropy_4 -b math_entropy_5 "${line}" -r "$1" 2>/yara/yara-error-log/$(basename ${line}).errorlog 1>/yara/yara-logs/$(basename ${line}).log &
	elif [ "$(basename "${line}")" = "fsf" ]; then
scan -Y -b ft_elf -b ft_gzip "${line}" -r "$1" 2>/yara/yara-error-log/$(basename ${line}).errorlog 1>/yara/yara-logs/$(basename ${line}).log &
	elif [ "$(basename "${line}")" = "malware-signatures" ]; then
scan -Y -b Rooter -b Warp -b Olyx "${line}" -r "$1" 2>/yara/yara-error-log/$(basename ${line}).errorlog 1>/yara/yara-logs/$(basename ${line}).log &
	elif [ "$(basename "${line}")" = "yaids" ]; then
scan -Y -b test_F_01 "${line}" -r "$1" 2>/yara/yara-error-log/$(basename ${line}).errorlog 1>/yara/yara-logs/$(basename ${line}).log &
	elif [ "$(basename "${line}")" = "reyara" ]; then
scan -Y -b inject_thread -b migrate_apc -b spreading_share -b sniff_audio -b rat_webcam -b anti_dbg -b network_http -b win_hook -b network_udp_sock -b network_tcp_listen -b network_tcp_socket -b cred_local -b win_private_profile -b win_token -b escalate_priv -b create_com_service -b win_mutex -b antisb_threatExpert -b sniff_lan -b network_dyndns -b network_dns -b keylogger -b disable_dep -b network_smtp_raw -b spreading_file -b persistence -b cred_ff -b screenshot -b win_files_operation -b create_process "${line}" -b win_registry -b network_dropper -r "$1" 2>/yara/yara-error-log/$(basename ${line}).errorlog 1>/yara/yara-logs/$(basename ${line}).log &
	elif [ "$(basename "${line}")" = "qs_old" ]; then
scan -Y -b theme_MH17 -b executable_win "${line}" -r "$1" 2>/yara/yara-error-log/$(basename ${line}).errorlog 1>/yara/yara-logs/$(basename ${line}).log &
	elif [ "$(basename "${line}")" = "DidierStevensSuite" ]; then
scan -Y -b http -b maldoc_structured_exception_handling -b maldoc_suspicious_strings -b maldoc_getEIP_method_1 -b maldoc_indirect_function_call_3 -b Contains_PE_File "${line}" -r "$1" 2>/yara/yara-error-log/$(basename ${line}).errorlog 1>/yara/yara-logs/$(basename ${line}).log &
	elif [ "$(basename "${line}")" = "Yara-rules" ]; then
scan -Y -b EXE_in_LNK "${line}" -r "$1" 2>/yara/yara-error-log/$(basename ${line}).errorlog 1>/yara/yara-logs/$(basename ${line}).log &
	elif [ "$(basename "${line}")" = "AlienVaultLabs" ]; then
scan -Y -b _Microsoft_Visual_Cpp_v70_DLL_ -b _Microsoft_Visual_Cpp_v50v60_MFC_ -b _Borland_Delphi_v60__v70_ -b _Borland_Delphi_v40__v50_ -b _Borland_Delphi_v30_ -b _Borland_Delphi_DLL_ -b dbgdetect_funcs "${line}" -r "$1" 2>/yara/yara-error-log/$(basename ${line}).errorlog 1>/yara/yara-logs/$(basename ${line}).log &
	elif [ "$(basename "${line}")" = "Burp-Yara-Rules" ]; then
scan -Y -b possible_includes_base64_packed_functions "${line}" -r "$1" 2>/yara/yara-error-log/$(basename ${line}).errorlog 1>/yara/yara-logs/$(basename ${line}).log &
	else
scan -Y "${line}" -r "$1" 2>/yara/yara-error-log/$(basename ${line}).errorlog 1>/yara/yara-logs/$(basename ${line}).log &
	fi
scan -b http -b ft_elf -b ft_gzip -b executable_win -b create_process -b win_registry -b win_files_operation -b win_hook -b win_mutex -b win_token -b create_service -b persistence -b math_entropy_1 -b math_entropy_2 -b math_entropy_3 -b math_entropy_4 -b math_entropy_5 -b maldoc_structured_exception_handling -b maldoc_getEIP_method_1 -b embedded_macho -b maldoc_indirect_function_call_3 -b maldoc_suspicious_strings -b test_F_01 -b domain -b contains_base64-Y -b Misc_Suspicious_Strings -b url -b IP -b android_meterpreter "${line}" -r "$1" 2>/yara/yara-error-log/$(basename ${line}).errorlog 1>/yara/yara-logs/$(basename ${line}).log &
done