#include <iostream>
#define MAX_ITEM_COUNT 998
#define CALL_FUNC() function()

typedef struct{ int num; char chad; } node;


int function(void)
{
	return 123;
};

int F_int(int number)
{

	number = 1234;
	return 1;
};

int F_int_ADD(int* numi)
{
	*numi = 123;

	return 0;
};

int F_node(node nin)
{

	nin.chad = 'C';
	nin.num = 888;

	return 0;
};



int main()
{
	using namespace std;

	int a = 1, b, c;
	struct{ int a; int b; } STRUE;

	int count = MAX_ITEM_COUNT;
	count = CALL_FUNC();

	F_int(a);

	F_int_ADD(&a);
	node abc;
	abc.num = 998;
	abc.chad = 'D';
	F_node(abc); 

	int arr[998];
	arr[123] = 765;
	b = 99;
	a = (123*44 + (321-b)/44 + 9)% 123;
	c = (a == b);

	a = 0;
	for (int i=0; i < 123; i++)
	{
		a += i;
	};

	int i = 123;
	a = 0;
	while (i)
	{
		a += i;
		i--;
	}; 

	switch (i)
	{
	case 1:	a = 1; break;
	case 2: a = 2; break;
	case 123:a = 123; break;
	default:a = 998; break;
	};

	return 0;
}