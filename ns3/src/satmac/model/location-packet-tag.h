#include "ns3/tag.h"
#include "ns3/packet.h"
#include "ns3/uinteger.h"

namespace ns3 {
class LocTag : public Tag
{
public:
  LocTag(){

  }
  LocTag(double dis){
	  m_distance = dis;

  }
  static TypeId GetTypeId (void);
  virtual TypeId GetInstanceTypeId (void) const;
  virtual uint32_t GetSerializedSize (void) const;
  virtual void Serialize (TagBuffer i) const;
  virtual void Deserialize (TagBuffer i);
  virtual void Print (std::ostream &os) const;

	double getDistance() {
		return m_distance;
	}

	void setDistance(double distance) {
		m_distance = distance;
	}

private:
  double m_distance;
};


}
