#!/epics/src/areaDetector/ADPilatus/iocs/pilatusIOC/bin/linux-x86_64/pilatusDetectorApp

< /epics/src/areaDetector/ADPilatus/iocs/pilatusIOC/iocBoot/iocPilatus/envPaths

dbLoadDatabase("$(TOP)/dbd/pilatusDetectorApp.dbd")
pilatusDetectorApp_registerRecordDeviceDriver(pdbbase)

epicsEnvSet("PREFIX", "XF:19IDC-ES{Det:Pil6M}")
epicsEnvSet("PORT",   "PIL")
epicsEnvSet("QSIZE",  "20")
epicsEnvSet("XSIZE",  "2463")
epicsEnvSet("YSIZE",  "2527")
epicsEnvSet("NCHANS", "2048")
epicsEnvSet("CBUFFS", "500")

epicsEnvSet("EPICS_DB_INCLUDE_PATH", "$(ADCORE)/db")

epicsEnvSet("EPICS_CA_MAX_ARRAY_BYTES", "99999999")

drvAsynIPPortConfigure("camserver","10.19.0.10:41234")

asynOctetSetInputEos("camserver", 0, "\030")
asynOctetSetOutputEos("camserver", 0, "\n")

pilatusDetectorConfig("$(PORT)", "camserver", $(XSIZE), $(YSIZE), 0, 0)
dbLoadRecords("$(ADPILATUS)/db/pilatus.template","P=$(PREFIX),R=cam1:,PORT=$(PORT),ADDR=0,TIMEOUT=1,CAMSERVER_PORT=camserver")

NDStdArraysConfigure("Image1", 5, 0, "$(PORT)", 0, 0)
dbLoadRecords("$(ADCORE)/db/NDStdArrays.template", "P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT),TYPE=Int32,FTVL=LONG,NELEMENTS=6224001")
#set_requestfile_path("$(TOP)/iocBoot/$(IOC)", "")

dbLoadRecords("$(IOCSTATS)/db/iocAdminSoft.db", "IOC=$(PREFIX)")

# Load all other plugins using commonPlugins.cmd
< $(ADCORE)/iocBoot/commonPlugins.cmd

set_requestfile_path("$(ADPILATUS)","pilatusApp/Db")
set_requestfile_path("$(ADCORE)", "ADApp/Db")
set_requestfile_path("$(AUTOSAVE)","as/req/")

set_savefile_path("as")

#asynSetTraceMask("$(PORT)",0,255)
#asynSetTraceMask("$(PORT)",0,3)

iocInit()

# save things every thirty seconds
create_monitor_set("auto_settings.req", 30,"P=$(PREFIX)")

