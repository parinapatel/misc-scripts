import socket
import time
import json
import requests
from luminol import anomaly_detector
import sys

def push_graphite_data(server, port, data):
    sock = socket.socket()
    sock.connect((server, port))
    for i in data:
        sock.sendall(i.encode('utf-8'))
    sock.close()


def get_graphite_data(metric_name, start_time, stop_time):
    remaining_time = int(start_time.lstrip("-").rstrip("h")) - 6
    if remaining_time > 0:
        raw_response = json.loads(requests.get(
            "https://graphite.aunalytics.com/render/?target=" +
            metric_name + "&from=-" + str(remaining_time) + "h&to=-6h&format=json").content)
        ts_list = raw_response[0]["datapoints"]
        raw_response = json.loads(requests.get(
            "https://graphite.aunalytics.com/render/?target=" +
            metric_name + "&from=-6h&to="+stop_time+"&format=json").content)
        ts_list += raw_response[0]["datapoints"]
    else:
        raw_response = json.loads(requests.get("https://graphite.aunalytics.com/render/?target=" +metric_name + "&from="+start_time+"&to="+stop_time+"&format=json").content)
        ts_list = raw_response[0]["datapoints"]
    temp = {}
    for i in ts_list:
        temp[i[1]] = i[0]
    return temp


def run_anomaly(metric_name, start_time, stop_time, push_ready=True):
    #  metric_name="devbeefydocker01.aunalytics.com.vmstat.cpu.user"
    # from_time="-24h"
    #  to_time="now"
    temp = get_graphite_data(metric_name, start_time, stop_time)
    detector = anomaly_detector.AnomalyDetector(temp)

    anomalies = detector.get_anomalies()
    # print (anomalies)

    anomalies_windows = []
    for ac in anomalies:
        # print(ac.get_time_window())
        anomalies_windows.append(ac.get_time_window())
    if push_ready is True:
        ra = []
        for c in anomalies_windows:
            if int(c[0]) > (time.time() - 3600):
                for r in range(c[0], c[1], 60):
                    ra.append(metric_name + "_anomaly 1 " + str(r) + "\n")
    else:
        ra = anomalies_windows
    return temp, ra


All_metrics_name = json.loads(requests.get("https://graphite.aunalytics.com/metrics/index.json").content)
for metrics_name in All_metrics_name:
    if ( "vmstat.cpu.user" in metrics_name or "vmstat.cpu.system" in metrics_name or "vmstat.cpu.waiting" in metrics_name ) and ("_anomaly" not in metrics_name):
        print(metrics_name)
        ts1, ra1 = run_anomaly(metrics_name, "-24h", "now", push_ready=True)
        push_graphite_data(sys.argv[1], 2003, ra1)
# print(ra1)
# ts2,ra2 = run_anomaly("beefydocker02.aunalytics.com.vmstat.cpu.user","-48h","-24h",push_ready=False)
# print(ra2)
# final_ra = ra1+ra2
# for time_period in final_ra:
#     time_space=(time_period[1]-time_period[0])/60
# #     print(time_space)
#     try:
#         if time_space > 1:
#             print (luminol.correlator.Correlator(ts1, ts2, time_period).get_correlation_result().coefficient)
#     except:
#         pass
