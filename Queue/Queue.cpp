#include <iostream>

typedef unsigned char byte;

int oq(byte *table,int &op , byte &cho)
{
	if (count==0)
		return 
};

int iq(byte *table ,int &ip, byte chin)
{

};

int pq(byte *table,int ip,int op)
{

};

int main()
{
	byte table[16];

	int ip = 0, op = 0;
	static int count = 0;
	byte chin;
	while (1)
	{
		chin = getchar();
		byte chtemp;
		if (chin == '-')
			oq(table,op,chtemp);
		if (chin == '+')
			pq(table,ip,op);
		if (((chin <= '9') && (chin >= '0')) || ((chin <= 'Z') && (chin >= 'A')))
			iq(table, ip, chin);
	}
}