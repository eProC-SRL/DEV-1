
#<<<<<<<<<<<<<<<<<<<< X314 - Lubbricaci�n 4.0 >>>>>>>>>>>>>>>>>>>>;



#Inicializo variables;
start
{
	read_io 0,p,4;	#Lee estado actual de v�lvula inversora y lo guardo en variable temporal "p";
	read_str 111,n,v;	#Leo el primer n�mero telef�nico de la agenda y lo cargo en "n";
};


#Leo las entradas digitales;
read_io 0,a,1;	#Auxiliar guardamotor;
read_io 0,b,2;	#Manual/Autom�tico;
read_io 0,c,3;	#Reset;
read_io 0,d,4;	#Conmutaci�n de v�lvula;
read_io 0,e,5;	#Bajo nivel;
read_io 0,f,6;	#Alto nivel;

#Leo las entradas analogicas;


#Pendiente/ levantar el seteo de los temporizadores (q, s y t) y contadores (r), remanencia?;



#------------------------------PROGRAMA------------------------------;

if C=1	#Sistema en alarma?;
{
	A=0;	#Desenergizo bomba de lubricaci�n;
	B=0;	#Apago testigo de marcha;
	D=0;	#Desenergizo bomba neum�tica;
	if c=1	#Pulsador de Reset presionado?;
	{
		j=0;
		k=0;
		l=0;
		R=0;
		i=0;
		if e=0
		{
			C=0;	#Apago testigo de alarma;
		};
	};
}
else	#sistema sin alarma;
{
	r=5;
	B=1;	#Enciendo testigo de marcha;
	if a=1	#Consulto estado de guardamotor;
	{
		C=1;	#Acuso alarma y enciendo testigo;
		write_str 5,v; #Carga el n�mero telef�nico (5=numero de telefono);
		write_str 4,'Proteccion termica actuada'; #Carga el texto del SMS (4=texto de SMS) y lo enviag;
	};
	if b=1	#Sistema en autom�tico?;
	{
		if R<r	#Sistema en ciclo?;
		{
			A=1;	#Energizo bomba de lubricaci�n;
#Pendiente/ si al invertir la v�lvula son estados concretos, detecto cambio de estado consultando por "d!p". Si en cambio me llega un pulso, reemplasar por "d>p" para leer el flanco positivo;
			if d!p	#Consulto si cambi� el estado de la v�lvula inversora?;
			{
				R=R+1;	#Actualizo contador de ciclos;
				U=U+1;	#Incremento contador de ciclos totales (se reinicia al desenergizar tablero);
				p=d;	#Actualizo auxiliar para detecci�n de flanco;
				j=1;
			};
			if j=1
			{
				timer t, 10000;
				j=2;
			};
			if j=2
			{
				check_timer t	#Tiempo de guardia de lubricaci�n excedido?;
				{
					C=1;	#Acuso alarma y enciendo testigo;
					if i=0 
					{
						write_str 5,v; #Carga el n�mero telef�nico (5=numero de telefono);
						write_str 4,'Falla de lubricaci�n'; #Carga el texto del SMS (4=texto de SMS) y lo envia;
						i=1;
					};
					j=0;
					};
			};		
		}
		else	#cumplido la cantidad de ciclos mando a reposo;
		{
			A=0;	#Desenergizo bomba de lubricaci�n;
			if k=0
			{
				timer q, 10000;
				k=1;
			};
			check_timer q	#Corriendo tiempo de espera;
			{
				k=0;
				R=0;	#Reinicio contador de ciclos;
			};	
		};	
	}
	else	#sistema en manual;
	{
			A=1;	#Energizo bomba de lubricaci�n;
	};	
};

#Rellenado de deposito, independiente al estado del sistema de lubricaci�n;
if f=1	#Si no esta en alto nivel;
{
	if e=1	#Y se deja de dar bajo nivel;
	{
		D=1;	#Energizo bomba neum�tica;
	};
	if D=1	#Si se energiz� bomba neum�tica;
	{
		if l=0
		{
			timer s, 10000;
			l=1;
			};
		
		check_timer s	#Tiempo de guardia de rellenado excedido?;
		{
			l=0;
			C=1;	#Acuso alarma y enciendo testigo; 
			if i=0
			{
				write_str 5, v; #Carga el n�mero telef�nico (5=numero de telefono);
				write_str 4,'Falta de lubricante en el deposito'; #Carga el texto del SMS (4=texto de SMS) y lo envia;
				i=1;
			};
			D=0;	#Desenergizo bomba neum�tica;
		};
	};
}
else	#Si lleg� a alto nivel;
{
	D=0;
};
		
#----------------------------------------------------------------------;


#Escribo las salidas;
write_io 1,1,A;	#Bomba lubricaci�n;
write_io 1,2,B;	#Testigo Marcha;
write_io 1,3,C;	#Testigo Alarma;
write_io 1,4,D;	#Bomba neum�tica;

end;

