
#<<<<<<<<<<<<<<<<<<<< X314 - Lubbricación 4.0 >>>>>>>>>>>>>>>>>>>>;

#Inicializo variables;
start
{
	#timer O,1000;	#Carga un timer de 1000 ms por única vez;
	timer q,10000;	#Carga un timer de 10000 ms por única vez;
	timer s,10000;	#Carga un timer de 10000 ms por única vez;
	timer t,10000;	#Carga un timer de 10000 ms por única vez;
	read_io 0,p,1;	#Lee estado actual de válvula inversora y lo guardo en variable temporal "p";
	read_str 111,n,v;	#Leo el primer número telefónico de la agenda y lo cargo en "n";
};

#Leo las entradas;
read_io 0,a,1;	#Auxiliar guardamotor;
read_io 0,b,2;	#Manual/Automático;
read_io 0,c,3;	#Reset;
read_io 0,d,4;	#Conmutación de válvula;
read_io 0,e,5;	#Bajo nivel;
read_io 0,f,6;	#Alto nivel;

#Pendiente/ levantar el seteo de los temporizadores (q, s y t) y contadores (r), remanencia?;

#Detecto cambio de estado en válvula inversora;
if d!p	#Cambió el estado de la válvula inversora?;
{
	P=1;	#Seteo pulso de inversión;
	p=d;	#Actualizo auxiliar para detección de flanco;
}
else	#No cambió estado de válvula inversora;
{
	P=0;	#Reseteo pulso de inversión;
};
#Pendiente/ evitar falsas lecturas (check_timer O, timer O,1000), tener en cuenta el filtro anti revotes que tienen las entradas por defecto 50ms (configurable 1-250ms);


#------------------------------PROGRAMA------------------------------;

if C=1	#Sistema en alarma?;
{
	A=0;	#Desenergizo bomba de lubricación;
	B=0;	#Apago testigo de marcha;
	D=0;	#Desenergizo bomba neumática;
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
		write_str 5,n; #Carga el número telefónico (5=numero de telefono);
		write_str 4,'Protección térmica actuada'; #Carga el texto del SMS (4=texto de SMS) y lo enviag;
	};
	if b=1	#Sistema en automático?;
	{
		if R<r	#Sistema en ciclo?;
		{
			A=1;	#Energizo bomba de lubricación;

#Pendiente/ si al invertir la válvula son estados concretos:;
			if P=0	#Aguardando inversión de válvula;
			{
				check_timer T	#Tiempo de guardia de lubricación excedido?;
				{
					timer T,t;	#Reinicio temporizador;
					C=1;	#Enciendo testigo de alarma;
					write_str 5,n; #Carga el número telefónico (5=numero de telefono);
					write_str 4,'Falla de lubricación'; #Carga el texto del SMS (4=texto de SMS) y lo envia;
				};
			}
			else	#Siguiente ciclo;
			{
				timer T,t;	#Reinicio temporizador;
				R=R+1;	#Actualizo contador de ciclos;
				U=U+1;	#Contador de ciclos totales (se reinicia al desenergizar tablero);
			};
			
#Pendiente/ si al invertir la válvula se detecta un pulso:;
			check_timer T	#Tiempo de guardia de lubricación excedido?;
			{
				timer T,t;	#Reinicio temporizador;
				C=1;	#Enciendo testigo de alarma;
				write_str 5,n; #Carga el número telefónico (5=numero de telefono);
				write_str 4,'Falla de lubricación'; #Carga el texto del SMS (4=texto de SMS) y lo envia;
			};
			if P=1	#Cambió estado de válvula inversora?;
			{
				timer T,t;	#Reinicio temporizador;
				R=R+1;	#Actualizo contador de ciclos;
				U=U+1;	#Contador de ciclos totales (se reinicia al desenergizar tablero);
			};
			
			
		}
		else	#Cumplido la cantidad de ciclos mando a reposo;
		{
			A=0;	#Desenergizo bomba de lubricación;
			check_timer Q	#Corriendo tiempo de espera;
			{
				timer Q,q;	#Reinicio temporizador;
				R=0;	#Reinicio contador de ciclos;
			};
		};	
	}
	else	#Sistema en manual;
	{
		A=1;	#Energizo bomba de lubricación;
	};	
};

#Rellenado de deposito, independiente al estado del sistema de lubricación;
if f=1	#Si no esta en alto nivel;
{
	if e=1	#Y se deja de dar bajo nibel;
	{
		D=1;	#Energizo bomba neumática;
	};
	if D=1	#Si se energizó bomba neumática;
	{
		check_timer S	#Tiempo de guardia de rrellenado excedido?;
		{
			timer S,s;	#Reinicio temporizador;
			C=1;	#Enciendo testigo de alarma;
			write_str 5,n; #Carga el número telefónico (5=numero de telefono);
			write_str 4,'Falta de lubricante en el deposito'; #Carga el texto del SMS (4=texto de SMS) y lo envia;
		};
	};
}
else	#Si llegó a alto nivel;
{
	timer S,s;	#Reinicio temporizador;
	D=0;	#Desenergizo bomba neumática;
};
		
#----------------------------------------------------------------------;


#Escribo las salidas;
write_io 1,1,A;	#Bomba lubricación;
write_io 1,2,B;	#Testigo Marcha;
write_io 1,3,C;	#Testigo Alarma;
write_io 1,4,D;	#Bomba neumática;

end;