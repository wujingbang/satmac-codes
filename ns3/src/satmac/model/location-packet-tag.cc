#include "location-packet-tag.h"

using namespace ns3;

TypeId
LocTag::GetTypeId (void)
{
  static TypeId tid = TypeId ("ns3::LocTag")
    .SetParent<Tag> ()
 //   .AddConstructor<LocTag> ()
//    .AddAttribute ("SimpleValue",
//                   "A simple value",
//                   EmptyAttributeValue (),
//                   MakeUintegerAccessor (&MyTag::GetSimpleValue),
//                   MakeUintegerChecker<uint8_t> ())
  ;
  return tid;
}
//uint8_t m_relayflag;
//uint8_t m_relay_mac[6];
TypeId
LocTag::GetInstanceTypeId (void) const
{
  return GetTypeId ();
}
uint32_t
LocTag::GetSerializedSize (void) const
{
  return sizeof(double);
}
void
LocTag::Serialize (TagBuffer i) const
{
  i.WriteDouble(m_distance);

}
void
LocTag::Deserialize (TagBuffer i)
{
	m_distance = i.ReadDouble();

}
void
LocTag::Print (std::ostream &os) const
{
  //os << "v=" << (uint32_t)m_relayflag;
}


