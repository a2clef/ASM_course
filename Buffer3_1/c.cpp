#include <stdio.h>
#include <stdlib.h>
#include <conio.h>

extern "C" char *bufdasm;			
extern "C" int  n;
extern "C" int iq(char * bufd, int *ipd, int chv);
extern "C" int oq(char * bufd, int *opd, char *chd);
extern "C" int pq(char * bufd, int ipv, int opv);


extern  "C"
{
	char chr;
	int  ip = 0;
	int  op = 0;
	void incp(int * p);
};

void incp(int * p)
{
	*p = (*p + 1) % 16;
};

int main()
{
	printf("���������ֻ��д��ĸ������'+','-',����ESC�˳�\n");
	chr = _getche();
	while (chr != 0x1b)
	{
		if (chr == '-')
		{
			oq(bufdasm, &op, &chr);
			if (chr != '-')
				printf("��ȡ��Ԫ��Ϊ:%c\n", chr);
		}
		else if (chr == '+')
		{
				printf("\n��ǰ��������Ϊ��");
				pq(bufdasm, ip, op);
				printf("�����±�Ϊ��%d ��β�±�Ϊ��%d Ԫ�ظ���Ϊ��%d\n", op, ip, n);
		}
		else if ((chr >= '0' && chr <= '9') || (chr >= 'A' && chr <= 'Z'))
			iq(bufdasm, &ip, chr);
		chr = _getche();
	};
	return    0;
};