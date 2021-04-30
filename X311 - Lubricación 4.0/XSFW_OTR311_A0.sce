
#<<<<<<<<<<<<<<<<<<<< X314 - Lubbricaci�n 4.0 >>>>>>>>>>>>>>>>>>>>;

#Inicializo variables;
start
{
	#timer O,1000;	#Carga un timer de 1000 ms por �nica vez;
	timer q,10000;	#Carga un timer de 10000 ms por �nica vez;
	timer s,10000;	#Carga un timer de 10000 ms por �nica vez;
	timer t,10000;	#Carga un timer de 10000 ms por �nica vez;
	read_io 0,p,1;	#Lee estado actual de v�lvula inversora y lo guardo en variable temporal "p";
	read_str 111,n,v;	#Leo el primer n�mero telef�nico de la agenda y lo cargo en "n";
};

#Leo las entradas;
read_io 0,a,1;	#Auxiliar guardamotor;
read_io 0,b,2;	#Manual/Autom�tico;
read_io 0,c,3;	#Reset;
read_io 0,d,4;	#Conmutaci�n de v�lvula;
read_io 0,e,5;	#Bajo nivel;
read_io 0,f,6;	#Alto nivel;

#Pendiente/ levantar el seteo de los temporizadores (q, s y t) y contadores (r), remanencia?;

#Detecto cambio de estado en v�lvula inversora;
if d!p	#Cambi� el estado de la v�lvula inversora?;
{
	P=1;	#Seteo pulso de inversi�n;
	p=d;	#Actualizo auxiliar para detecci�n de flanco;
}
else	#No cambi� estado de v�lvula inversora;
{
	P=0;	#Reseteo pulso de inversi�n;
};
#Pendiente/ evitar falsas lecturas (check_timer O, timer O,1000), tener en cuenta el filtro anti revotes que tienen las entradas por defecto 50ms (configurable 1-250ms);


#------------------------------PROGRAMA------------------------------;

if C=1	#Sistema en alarma?;
{
	A=0;	#Desenergizo bomba de lubricaci�n;
	B=0;	#Apago testigo de marcha;
	D=0;	#Desenergizo bomba neum�tica;
	if c=1	#Pulsador de Reset presionado?;
	{
#Pendiente/ definir la necesidad de consultar por nivel de deposito para reiniciar (if e=0);
			C=0;	#Apago testigo de alarma;
	};
}
else	#Sistema sin alarma;
{
	B=1;	#Enciendo testigo de marcha;
	if a=1	#Consulto estado de guardamotor;
	{
		C=1;	#Enciendo testigo de alarma;
		write_str 5,n; #Carga el n�mero telef�nico (5=numero de telefono);
		write_str 4,'Protecci�n t�rmica actuada'; #Carga el texto del SMS (4=texto de SMS) y lo enviag;
	};
	if b=1	#Sistema en autom�tico?;
	{
		if R<r	#Sistema en ciclo?;
		{
			A=1;	#Energizo bomba de lubricaci�n;

#Pendiente/ si al invertir la v�lvula son estados concretos:;
			if P=0	#Aguardando inversi�n de v�lvula;
			{
				check_timer T	#Tiempo de guardia de lubricaci�n excedido?;
				{
					timer T,t;	#Reinicio temporizador;
					C=1;	#Enciendo testigo de alarma;
					write_str 5,n; #Carga el n�mero telef�nico (5=numero de telefono);
					write_str 4,'Falla de lubricaci�n'; #Carga el texto del SMS (4=texto de SMS) y lo envia;
				};
			}
			else	#Siguiente ciclo;
			{
				timer T,t;	#Reinicio temporizador;
				R=R+1;	#Actualizo contador de ciclos;
				U=U+1;	#Contador de ciclos totales (se reinicia al desenergizar tablero);
			};
			
#Pendiente/ si al invertir la v�lvula se detecta un pulso:;
			check_timer T	#Tiempo de guardia de lubricaci�n excedido?;
			{
				timer T,t;	#Reinicio temporizador;
				C=1;	#Enciendo testigo de alarma;
				write_str 5,n; #Carga el n�mero telef�nico (5=numero de telefono);
				write_str 4,'Falla de lubricaci�n'; #Carga el texto del SMS (4=texto de SMS) y lo envia;
			};
			if P=1	#Cambi� estado de v�lvula inversora?;
			{
				timer T,t;	#Reinicio temporizador;
				R=R+1;	#Actualizo contador de ciclos;
				U=U+1;	#Contador de ciclos totales (se reinicia al desenergizar tablero);
			};
			
			
		}
		else	#Cumplido la cantidad de ciclos mando a reposo;
		{
			A=0;	#Desenergizo bomba de lubricaci�n;
			check_timer Q	#Corriendo tiempo de espera;
			{
				timer Q,q;	#Reinicio temporizador;
				R=0;	#Reinicio contador de ciclos;
			};
		};	
	}
	else	#Sistema en manual;
	{
		A=1;	#Energizo bomba de lubricaci�n;
	};	
};

#Rellenado de deposito, independiente al estado del sistema de lubricaci�n;
if f=1	#Si no esta en alto nivel;
{
	if e=1	#Y se deja de dar bajo nibel;
	{
		D=1;	#Energizo bomba neum�tica;
	};
	if D=1	#Si se energiz� bomba neum�tica;
	{
		check_timer S	#Tiempo de guardia de rrellenado excedido?;
		{
			timer S,s;	#Reinicio temporizador;
			C=1;	#Enciendo testigo de alarma;
			write_str 5,n; #Carga el n�mero telef�nico (5=numero de telefono);
			write_str 4,'Falta de lubricante en el deposito'; #Carga el texto del SMS (4=texto de SMS) y lo envia;
		};
	};
}
else	#Si lleg� a alto nivel;
{
	timer S,s;	#Reinicio temporizador;
	D=0;	#Desenergizo bomba neum�tica;
};
		
#----------------------------------------------------------------------;


#Escribo las salidas;
write_io 1,1,A;	#Bomba lubricaci�n;
write_io 1,2,B;	#Testigo Marcha;
write_io 1,3,C;	#Testigo Alarma;
write_io 1,4,D;	#Bomba neum�tica;

end;