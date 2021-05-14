/* -*- Mode:C++; c-file-style:"gnu"; indent-tabs-mode:nil; -*- */
/*
  This software was developed at the National Institute of Standards and
  Technology by employees of the Federal Government in the course of
  their official duties. Pursuant to titleElement 17 Section 105 of the United
  States Code this software is not subject to copyright protection and
  is in the public domain.
  NIST assumes no responsibility whatsoever for its use by other parties,
  and makes no guarantees, expressed or implied, about its quality,
  reliability, or any other characteristic.

  We would appreciate acknowledgement if the software is used.

  NIST ALLOWS FREE USE OF THIS SOFTWARE IN ITS "AS IS" CONDITION AND
  DISCLAIM ANY LIABILITY OF ANY KIND FOR ANY DAMAGES WHATSOEVER RESULTING
  FROM THE USE OF THIS SOFTWARE.

 * Modified by: Fabian Eckermann <fabian.eckermann@udo.edu> (CNI)
 *              Moritz Kahlert <moritz.kahlert@udo.edu> (CNI)
 */

#include "ns3/lte-helper.h"
#include "ns3/core-module.h"
#include "ns3/network-module.h"
#include "ns3/ipv4-global-routing-helper.h"
#include "ns3/internet-module.h"
#include "ns3/mobility-module.h"
#include "ns3/lte-module.h"
#include "ns3/applications-module.h"
#include "ns3/point-to-point-helper.h"
#include "ns3/lte-v2x-helper.h"
#include "ns3/config-store.h"
#include "ns3/lte-hex-grid-enb-topology-helper.h"
#include <ns3/buildings-helper.h>
#include <ns3/cni-urbanmicrocell-propagation-loss-model.h>
#include <ns3/constant-position-mobility-model.h>
#include <ns3/spectrum-analyzer-helper.h>
#include <ns3/multi-model-spectrum-channel.h>
#include "ns3/ns2-mobility-helper.h"
#include <cfloat>
#include <sstream>

#include "ns3/wifi-module.h"
#include "ns3/v4ping-helper.h"
#include "ns3/applications-module.h"
#include "ns3/itu-r-1411-los-propagation-loss-model.h"
#include "ns3/ocb-wifi-mac.h"
#include "ns3/wifi-80211p-helper.h"
#include "ns3/wave-mac-helper.h"
#include "ns3/flow-monitor-module.h"
#include "ns3/config-store-module.h"
#include "ns3/integer.h"
//#include "ns3/wave-bsm-helper.h"
#include "ns3/wave-helper.h"
#include "ns3/topology.h"

#include "ns3/wave-bsm-helper.h"
#include "ns3/flow-monitor-helper.h"

//--building=1 --buildingfile=/home/wu/workspace/ns-3_c-v2x-master/src/wave/examples/9gong/buildings.xml --tracefile=/home/wu/workspace/ns-3_c-v2x-master/src/wave/examples/9gong/9gong.ns2
//./waf --run "v2x_communication_example2 --numVeh=900 --building=0 --buildingfile=/home/wu/workspace/ns-3_c-v2x-master/src/wave/examples/newyork/buildings.xml --tracefile=/home/wu/workspace/ns-3_c-v2x-master/src/wave/examples/newyork/newyorkmobility.ns2"

using namespace ns3;

NS_LOG_COMPONENT_DEFINE ("v2x_communication_mode_4");

// Output 
std::string simtime = "log_simtime_v2x.csv"; 
//std::string rx_data = "log_rx_data_v2x.csv";
//std::string tx_data = "log_tx_data_v2x.csv";
//std::string connections = "log_connections_v2x.csv";
//std::string positions = "log_positions_v2x.csv";

//Ptr<OutputStreamWrapper> log_connections;
Ptr<OutputStreamWrapper> log_simtime;
//Ptr<OutputStreamWrapper> log_positions;
//Ptr<OutputStreamWrapper> log_rx_data;
//Ptr<OutputStreamWrapper> log_tx_data;

// Global variables
uint32_t ctr_totRx = 0; 	// Counter for total received packets
uint32_t ctr_totTx = 0; 	// Counter for total transmitted packets
uint16_t lenCam = 100;  // Length of CAM message in bytes [50-300 Bytes]
double baseline= 2550.0;     // Baseline distance in meter (150m for urban, 320m for freeway)

int testing = 0;

int m_tdma_enable = 1;

// Initialize some values
// NOTE: commandline parser is currently (05.04.2019) not working for uint8_t (Bug 2916)

// Create node container to hold all UEs
//NodeContainer allNodesCon;

NodeContainer allNodesCon;
NetDeviceContainer tdmaDataDevices;
Ipv4InterfaceContainer tdmaIpInterfaces;

uint16_t simTime = 100;                 // Simulation time in seconds
uint32_t numVeh = 2;                  // Number of vehicles
double txPower = 6.7;                // Transmission power in dBm
int testdistance = 160;

double frameadj_cut_ratio_ths_ = 0.4;
double frameadj_cut_ratio_ehs_ = 0.6;
double frameadj_exp_ratio_ = 0.9;
int adjEna = 1;
int adjFrameEna =1;
int framelen = 64;
int framelenUp = 128;
int framelenLow = 32;

int m_wavePacketSize = 200;
double m_waveInterval = 0.1;
double m_gpsAccuracyNs = 40; ///< GPS accuracy
std::vector <double> m_txSafetyRanges; ///< list of ranges
double m_txMaxDelayMs = 10;
int64_t m_streamIndex = 0;
WaveBsmHelper m_waveBsmHelper; ///< helper

std::string tracefile;                  // Name of the tracefile
std::string tracefile_200 = "/home/wu/workspace/ns-3_c-v2x-master/mobility/beijing3/map.mobility-200n.tcl";
std::string tracefile_400 = "/home/wu/workspace/ns-3_c-v2x-master/mobility/beijing3/map.mobility-400n.tcl";
std::string tracefile_600 = "/home/wu/workspace/ns-3_c-v2x-master/mobility/beijing3/map.mobility-600n.tcl";
std::string tracefile_800 = "/home/wu/workspace/ns-3_c-v2x-master/mobility/beijing3/map.mobility-800n.tcl";
std::string tracefile_1000 = "/home/wu/workspace/ns-3_c-v2x-master/mobility/beijing3/map.mobility-1000n.tcl";               // Name of the tracefile
std::string tracefile_1200 = "/home/wu/workspace/ns-3_c-v2x-master/mobility/beijing3/map.mobility-1200n.tcl";
//std::string tracefile="/home/wu/workspace/ns-3_c-v2x-master/mobility/city-big/updated-350-adj-all_1.tcl";                  // Name of the tracefile

std::string lpfoutfile = "lpf-output.txt";

//std::string m_flowOutFile;
//std::string m_outputPrefix;
//std::string m_netFileString;
//std::string m_osmFileString;

int m_loadBuildings = 0;
std::string bldgFile;// = "src/wave/examples/9gong/buildings.xml";

// Responders users 
//NodeContainer ueVeh;

static uint32_t collision_count=0;

void 
PrintStatus (uint32_t s_period, Ptr<OutputStreamWrapper> log_simtime)
{

	*log_simtime->GetStream() << Simulator::Now ().GetSeconds () << " Collision "<<collision_count << std::endl;
    std::cout << "t=" <<  Simulator::Now().GetSeconds() <<  " Collision "<<collision_count <<" Rx " << m_waveBsmHelper.GetWaveBsmStats ()->GetRxPktCount () << std::endl;
    Simulator::Schedule(Seconds(s_period), &PrintStatus, s_period,log_simtime);
}

void
PhyRxCollisionDropTrace(Ptr<const Packet> p)
{
	collision_count++;
}

void config();
void CheckThroughput ();

int
main (int argc, char *argv[])
  {

    LogComponentEnable ("v2x_communication_mode_4", LOG_INFO);

    // Command line arguments
    CommandLine cmd;
    cmd.AddValue ("test", "", testing);
    cmd.AddValue ("time", "Simulation Time", simTime);
    cmd.AddValue ("node", "Number of Vehicles", numVeh);
     cmd.AddValue ("lenCam", "Packetsize in Bytes", lenCam);
    cmd.AddValue ("log_collision", "name of the simtime logfile", simtime);
    cmd.AddValue ("log_lpf", "name of the lpf logfile", lpfoutfile);

//    cmd.AddValue ("log_rx_data", "name of the rx data logfile", rx_data);
//    cmd.AddValue ("log_tx_data", "name of the tx data logfile", tx_data);
//    cmd.AddValue ("tracefile", "Path of ns-3 tracefile", tracefile);
    //cmd.AddValue ("baseline", "Distance in which messages are transmitted and must be received", baseline);

    cmd.AddValue ("tdma", "enable tdma or not (802.11p)", m_tdma_enable);

    cmd.AddValue ("bsm", "(WAVE) BSM size (bytes)", m_wavePacketSize);
    cmd.AddValue ("interval", "(WAVE) BSM interval (s)", m_waveInterval);


    cmd.AddValue ("FrameadjExpRatio", "",  frameadj_exp_ratio_);
    cmd.AddValue ("FrameadjCutRatioThs", "",  frameadj_cut_ratio_ths_);
    cmd.AddValue ("FrameadjCutRatioEhs", "",  frameadj_cut_ratio_ehs_);
    cmd.AddValue ("AdjEnable", "",  adjEna);
    cmd.AddValue ("AdjFrameEnable", "",  adjFrameEna);
    cmd.AddValue ("FrameLen", "",  framelen);
    cmd.AddValue ("FrameLenUp", "",  framelenUp);
    cmd.AddValue ("FrameLenLow", "",  framelenLow);

    //NOTICE:obstacle shadowing model is disabled.
    cmd.AddValue ("building", "Use obstacle building shadowing.", m_loadBuildings);
    cmd.AddValue ("buildingfile", "Path of building file", bldgFile);

    //--building=1 --tracefile=/home/wu/workspace/ns-3_c-v2x-master/src/wave/examples/newyork/newyorkmobility.ns2 --buildingfile=/home/wu/workspace/ns-3_c-v2x-master/src/wave/examples/newyork/buildings.xml
    cmd.Parse (argc, argv);

    AsciiTraceHelper ascii;
    log_simtime = ascii.CreateFileStream(simtime);
//    log_rx_data = ascii.CreateFileStream(rx_data);
//    log_tx_data = ascii.CreateFileStream(tx_data);
//    log_connections = ascii.CreateFileStream(connections);
//    log_positions = ascii.CreateFileStream(positions);

    NS_LOG_INFO ("Starting network configuration...");

    config();


	//*log_simtime->GetStream() << "Simtime;TotalRx;TotalTx;PRR" << std::endl;
	Simulator::Schedule(Seconds(1), &PrintStatus, 1, log_simtime);
	CheckThroughput ();

	NS_LOG_INFO ("Starting Simulation...");
	Simulator::Stop(MilliSeconds(simTime*1000+40));
	Simulator::Run();
	Simulator::Destroy();

	NS_LOG_INFO("Simulation done.");
	return 0;
}
/* ********************************************************
 * 			TDMA  Configuration
 *********************************************************/
void satmac_par_config(){

	Config::Set ("/NodeList/*/DeviceList/*/$ns3::WifiNetDevice/Mac/Tdma/AdjEnable", IntegerValue(adjEna));
	Config::Set ("/NodeList/*/DeviceList/*/$ns3::WifiNetDevice/Mac/Tdma/AdjFrameEnable", IntegerValue(adjFrameEna));

	Config::Set ("/NodeList/*/DeviceList/*/$ns3::WifiNetDevice/Mac/Tdma/FrameLen", IntegerValue(framelen));
	Config::Set ("/NodeList/*/DeviceList/*/$ns3::WifiNetDevice/Mac/Tdma/AdjFrameLowerBound", IntegerValue(framelenLow));
	Config::Set ("/NodeList/*/DeviceList/*/$ns3::WifiNetDevice/Mac/Tdma/AdjFrameUpperBound", IntegerValue(framelenUp));

	Config::Set ("/NodeList/*/DeviceList/*/$ns3::WifiNetDevice/Mac/Tdma/SlotMemory", IntegerValue(1));
	Config::Set ("/NodeList/*/DeviceList/*/$ns3::WifiNetDevice/Mac/Tdma/SlotLife", IntegerValue(3));
	Config::Set ("/NodeList/*/DeviceList/*/$ns3::WifiNetDevice/Mac/Tdma/C3HThreshold", IntegerValue(3));
	Config::Set ("/NodeList/*/DeviceList/*/$ns3::WifiNetDevice/Mac/Tdma/AdjThreshold", IntegerValue(3));
	Config::Set ("/NodeList/*/DeviceList/*/$ns3::WifiNetDevice/Mac/Tdma/RandomBchIfSingle", IntegerValue(0));
	Config::Set ("/NodeList/*/DeviceList/*/$ns3::WifiNetDevice/Mac/Tdma/ChooseBchRandomSwitch", IntegerValue(1));

	Config::Set ("/NodeList/*/DeviceList/*/$ns3::WifiNetDevice/Mac/Tdma/FrameadjExpRatio", DoubleValue(frameadj_exp_ratio_));
	Config::Set ("/NodeList/*/DeviceList/*/$ns3::WifiNetDevice/Mac/Tdma/FrameadjCutRatioThs", DoubleValue(frameadj_cut_ratio_ths_));
	Config::Set ("/NodeList/*/DeviceList/*/$ns3::WifiNetDevice/Mac/Tdma/FrameadjCutRatioEhs", DoubleValue(frameadj_cut_ratio_ehs_));

	Config::Set ("/NodeList/*/DeviceList/*/$ns3::WifiNetDevice/Mac/Tdma/LPFTraceFile", StringValue(lpfoutfile));

}
void config()
{
	//double freq = 5.9e9;
//	if (m_lossModel == 1)
//	{
//	  m_lossModelName = "ns3::FriisPropagationLossModel";
//	}
//	else if (m_lossModel == 2)
//	{
//	  m_lossModelName = "ns3::ItuR1411LosPropagationLossModel";
//	}
//	else if (m_lossModel == 3)
//	{
//	  m_lossModelName = "ns3::TwoRayGroundPropagationLossModel";
//	}
//	else if (m_lossModel == 4)
//	{
//	  m_lossModelName = "ns3::LogDistancePropagationLossModel";
//	}
//	else
//	{
//	  // Unsupported propagation loss model.
//	  // Treating as ERROR
//	}

	std::cout << "Creating " << (unsigned)numVeh << " nodes " << "\n";
	allNodesCon.Create (numVeh);
	// Name nodes
	for (uint32_t i = 0; i < numVeh; ++i)
	 {
	   std::ostringstream os;
	   // Set the Node name to the corresponding IP host address
	   os << "node-" << i+1;
	   Names::Add (os.str (), allNodesCon.Get (i));
	 }

	YansWifiChannelHelper wifiChannel2;
	wifiChannel2.SetPropagationDelay ("ns3::ConstantSpeedPropagationDelayModel");
//	if (m_lossModel == 3)
//	{
//	  // two-ray requires antenna height (else defaults to Friss)
//	  wifiChannel2.AddPropagationLoss (m_lossModelName, "Frequency", DoubleValue (freq), "HeightAboveZ", DoubleValue (1.5));
//	}
//	else
//	{
//	  wifiChannel2.AddPropagationLoss (m_lossModelName, "Frequency", DoubleValue (freq));
//	}


//	wifiChannel2.AddPropagationLoss ("ns3::ObstacleShadowingPropagationLossModel", "MaxDistance", UintegerValue(1000));
//		Config::SetDefault ("ns3::CniUrbanmicrocellPropagationLossModel::Frequency", DoubleValue(5800e6));
//		wifiChannel2.AddPropagationLoss ("ns3::CniUrbanmicrocellPropagationLossModel");

//	if (m_loadBuildings == 1) {
//		wifiChannel2.AddPropagationLoss ("ns3::ObstacleShadowingPropagationLossModel", "MaxDistance", UintegerValue(1000));
//		wifiChannel2.AddPropagationLoss ("ns3::NakagamiPropagationLossModel");
//	}
//	else {
//		//wifiChannel2.AddPropagationLoss ("ns3::NakagamiPropagationLossModel");
		Config::SetDefault ("ns3::CniUrbanmicrocellPropagationLossModel::Frequency", DoubleValue(5800e6));
		Config::SetDefault ("ns3::CniUrbanmicrocellPropagationLossModel::LosEnabled", BooleanValue(true));
		wifiChannel2.AddPropagationLoss ("ns3::CniUrbanmicrocellPropagationLossModel");
//	}
	Ptr<YansWifiChannel> channel = wifiChannel2.Create ();
	YansWifiPhyHelper wifiPhy2 =  YansWifiPhyHelper::Default ();
	wifiPhy2.SetChannel (channel);
	wifiPhy2.SetPcapDataLinkType (YansWifiPhyHelper::DLT_IEEE802_11);
	NqosWaveMacHelper wifi80211pMac = NqosWaveMacHelper::Default ();
	Wifi80211pHelper wifi80211p = Wifi80211pHelper::Default ();

	// Setup 802.11p stuff
	wifi80211p.SetRemoteStationManager ("ns3::ConstantRateWifiManager",
								   "DataMode",StringValue ("OfdmRate12MbpsBW10MHz"),
								   "ControlMode",StringValue ("OfdmRate12MbpsBW10MHz"),
				   "NonUnicastMode", StringValue ("OfdmRate12MbpsBW10MHz"));

	// Set Tx Power
	wifiPhy2.Set ("TxPowerStart",DoubleValue (txPower));
	wifiPhy2.Set ("TxPowerEnd", DoubleValue (txPower));

	wifiPhy2.Set ("EnergyDetectionThreshold", DoubleValue (-85));//about 200m

	tdmaDataDevices = wifi80211p.Install (wifiPhy2, wifi80211pMac, allNodesCon, m_tdma_enable);

	if (m_tdma_enable) {
		//Config TDMA parameters.
		satmac_par_config();

	}
	//InstallInternetStack
    // Install the IP stack on the UEs
    NS_LOG_INFO ("Installing IP stack...");
    InternetStackHelper internet;
    internet.Install (allNodesCon);

	Ipv4AddressHelper addressAdhocData;
	addressAdhocData.SetBase ("10.1.0.0", "255.255.0.0");
	tdmaIpInterfaces = addressAdhocData.Assign (tdmaDataDevices);

    // Create Ns2MobilityHelper with the specified trace log file as parameter
//    Ns2MobilityHelper ns2 = Ns2MobilityHelper (m_traceFile);
//    ns2.Install (); // configure movements for each node, while reading trace file

    if (testing)
    {
    	std::cout<<"@@@@@@TESTING MODE@@@@@@" << std::endl;
		// Install constant random positions
		MobilityHelper mobVeh;
		mobVeh.SetMobilityModel("ns3::ConstantPositionMobilityModel");

		Ptr<ListPositionAllocator> staticVeh[allNodesCon.GetN()];
		Ptr<ListPositionAllocator> positionAlloc = CreateObject<ListPositionAllocator> ();
		positionAlloc->Add (Vector (0, 0, 0));
		positionAlloc->Add (Vector (0, testdistance, 0));
		mobVeh.SetPositionAllocator(positionAlloc);
		mobVeh.Install (allNodesCon);

//		MobilityHelper mobVeh;
//		mobVeh.SetMobilityModel("ns3::ConstantPositionMobilityModel");
//		Ptr<ListPositionAllocator> staticVeh[allNodesCon.GetN()];
//		for (uint16_t i=0; i<allNodesCon.GetN();i++)
//		{
//			staticVeh[i] = CreateObject<ListPositionAllocator>();
//			Ptr<UniformRandomVariable> rand = CreateObject<UniformRandomVariable> ();
//			int x = rand->GetValue (0,2000);
//			int y = rand->GetValue (0,2000);
//			double z = 0;
//			staticVeh[i]->Add(Vector(x,y,z));
//			mobVeh.SetPositionAllocator(staticVeh[i]);
//			mobVeh.Install(allNodesCon.Get(i));
//		}
    } else {

    	if (numVeh <=201)
    		tracefile = tracefile_200;
    	else if (numVeh <=401)
    		tracefile = tracefile_400;
    	else if (numVeh <=601)
    		tracefile = tracefile_600;
    	else if (numVeh <=801)
    		tracefile = tracefile_800;
    	else if (numVeh <=1001)
    		tracefile = tracefile_1000;
       	else if (numVeh <=1201)
        		tracefile = tracefile_1200;

        std::cout<<"===Loading trace file...===" << tracefile << std::endl;

        Ns2MobilityHelper ns2 = Ns2MobilityHelper(tracefile);
        ns2.Install();
    }

    if (!bldgFile.empty()) {
    	std::cout<<"Loading buildings file " << bldgFile << std::endl;
    	Topology::LoadBuildings(bldgFile);
    }

    if (!m_tdma_enable) {

    	  int chAccessMode = 0;
    	  m_txSafetyRanges.resize (1, 0);
    	  m_txSafetyRanges[0] = 200;

    	  m_waveBsmHelper.GetWaveBsmStats ()->SetLogging (0);
    	  // initially assume all nodes are not moving
    	  WaveBsmHelper::GetNodesMoving ().resize (numVeh, 1);

    	  m_waveBsmHelper.Install (tdmaIpInterfaces,
    	                           Seconds (simTime),
    	                           m_wavePacketSize,
    	                           Seconds (m_waveInterval),
    	                           // GPS accuracy (i.e, clock drift), in number of ns
    	                           m_gpsAccuracyNs,
    	                           m_txSafetyRanges,
    	                           chAccessMode,
    	                           // tx max delay before transmit, in ms
    	                           MilliSeconds (m_txMaxDelayMs));

    	  // fix random number streams
    	  m_streamIndex += m_waveBsmHelper.AssignStreams (allNodesCon, m_streamIndex);


    }

//    uint16_t application_port = 8000; // Application port to TX/RX
//    //Individual Socket Traffic Broadcast everyone
//    Ptr<Socket> host = Socket::CreateSocket(tdmaDataDevices.Get(0)->GetNode(),TypeId::LookupByName ("ns3::UdpSocketFactory"));
//    host->Bind(InetSocketAddress (tdmaIpInterfaces.GetAddress(0), application_port));
//    host->Connect(InetSocketAddress(tdmaIpInterfaces.GetAddress(1),application_port));
//    host->SetAllowBroadcast(true);
//    //host->ShutdownRecv();
//
//    Ptr<Socket> sink = Socket::CreateSocket(tdmaDataDevices.Get(1)->GetNode(),TypeId::LookupByName ("ns3::UdpSocketFactory"));
//    sink->Bind(InetSocketAddress (Ipv4Address::GetAny (), application_port));
//    sink->SetRecvCallback (MakeCallback (&ReceivePacket));

    //Ptr<TdmaSatmac> tdmaMac = DynamicCast<TdmaSatmac>( tdmaDataDevices.Get (0)->GetObject<WifiNetDevice> ()->GetMac () );

//    Ptr<NetDevice> t1 = tdmaDataDevices.Get (0);
//    Ptr<WifiNetDevice> t2 = t1->GetObject<WifiNetDevice> ();
//    Ptr<OcbWifiMac> t3 = DynamicCast<OcbWifiMac>(t2->GetMac ());
//    Ptr<TdmaSatmac> t4 = DynamicCast<TdmaSatmac> (t3->GetTdmaObject());
//    //t4->TraceConnectWithoutContext ("BCHTrace", MakeBoundCallback (&SidelinkV2xAnnouncementMacTrace, host));
//    t4->TraceConnectWithoutContext ("BCHTrace", MakeBoundCallback (&SidelinkV2xAnnouncementMacTrace, host));
    tdmaDataDevices.Get (0) ->GetObject<WifiNetDevice> () -> GetPhy ()->TraceConnectWithoutContext ("PhyRxCollisionDrop", MakeCallback (&PhyRxCollisionDropTrace));
//PhyRxCollisionDrop
}


void CheckThroughput ()
{
//  double wavePDR = 0.0;
  int wavePktsSent = m_waveBsmHelper.GetWaveBsmStats ()->GetTxPktCount ();
  int wavePktsReceived = m_waveBsmHelper.GetWaveBsmStats ()->GetRxPktCount ();
//  if (wavePktsSent > 0)
//    {
//      int wavePktsReceived = m_waveBsmHelper.GetWaveBsmStats ()->GetRxPktCount ();
////      wavePDR = (double) wavePktsReceived / (double) wavePktsSent;
//    }

//  int waveExpectedRxPktCount = m_waveBsmHelper.GetWaveBsmStats ()->GetExpectedRxPktCount (1);
//  int waveRxPktInRangeCount = m_waveBsmHelper.GetWaveBsmStats ()->GetRxPktInRangeCount (1);
//  double wavePDR1_2 = m_waveBsmHelper.GetWaveBsmStats ()->GetBsmPdr (1);


  // calculate MAC/PHY overhead (mac-phy-oh)
  // total WAVE BSM bytes sent
//  uint32_t cumulativeWaveBsmBytes = m_waveBsmHelper.GetWaveBsmStats ()->GetTxByteCount ();


  std::ofstream out (lpfoutfile.c_str (), std::ios::app);

//  NS_LOG_UNCOND ("At t=" << (Simulator::Now ()).GetSeconds () << "s BSM_PDR1=" << wavePDR1_2 );

  //LPF output format
  out << "m "<<(Simulator::Now ()).GetMilliSeconds ()<<" t["<<0<<"] _"<<0<<
  	"_ LPF "<<0<<" "<<0<<" "<<0<<" "<<
  	0<<" "<<0<<" "<<0<<" "<<
  	0<<" "<<wavePktsSent<<" "<<wavePktsReceived<<" "<<
  	0<<" "<<0<<" "<<0<<" "<<0
	<<" "<<"x:" << 0 <<" "<<"y"<< 0 <<" "<<0<<std::endl;

  out.close ();


//  m_waveBsmHelper.GetWaveBsmStats ()->SetRxPktCount (0);
//  m_waveBsmHelper.GetWaveBsmStats ()->SetTxPktCount (0);
//  for (int index = 1; index <= 1; index++)
//    {
//      m_waveBsmHelper.GetWaveBsmStats ()->SetExpectedRxPktCount (index, 0);
//      m_waveBsmHelper.GetWaveBsmStats ()->SetRxPktInRangeCount (index, 0);
//    }

//  double currentTime = (Simulator::Now ()).GetSeconds ();
//  if (currentTime <= (double) m_cumulativeBsmCaptureStart)
//    {
//      for (int index = 1; index <= 10; index++)
//        {
//          m_waveBsmHelper.GetWaveBsmStats ()->ResetTotalRxPktCounts (index);
//        }
//    }

  Simulator::Schedule (Seconds (1), &CheckThroughput);
}

