%Usefull Links
%https://www.faa.gov/about/office_org/headquarters_offices/avs/offices/aam/cami/library/online_libraries/aerospace_medicine/tutorial/media/III.4.1.5_Maneuvering_in_Space.pdf
%http://www.bogan.ca/orbits/kepler/orbteqtn.html

%Ideas:
%Make it so deltav can be calculated from anywhere in orbit

clear,clc;

%In bodies the order will be: Names, Mass, Radius, Highest Point

system=input('Choose System: ','s');
filename=[system,'.txt'];

fid=fopen(filename);
bodies=textscan(fid,'%s %f %f %f');
fclose(fid);

Names=bodies{:,1};
Mass=bodies{:,2};
Radius=bodies{:,3};
answer=1;
resonance='No';
target='No';


while answer==1
  a=1;
  body=input('Choose a body: ','s');
  target=input('Do you have a target vessel? ','s');

  while strcmp(body,Names(a))==0
    a=a+1;
  end

  global G; G=6.67408e-11;
  global M; M=Mass(a);
  global i; i=a;
  global Atm; Atm=bodies{1,4};

  if strcmp(target,'Yes')==1
    [r1,r2,altitudei,altitudef]=altitudes(Radius);
    deltav=abs(Vellipse(r1,r2)-Vellipse(r1,r1));
    deltav2=abs(Vellipse(r2,r2)-Vellipse(r2,r1));

    omega=Vellipse(r2,r2)/r2;
    TOF=pi*sqrt(((r1+r2)/2)^3/(G*M));
    theta_lead=omega*TOF;
    phase_angle=(180/(2*pi))*(pi-theta_lead);

    clc;

    fprintf('The delta v required for a transfer to the target from %1.2fm is %1.2fm/s\n',altitudei,deltav);
    fprintf('The delta v required to circularize with the target at altitude %1.2fm is %1.2fm/s\n',altitudef,deltav2)
    fprintf('The phase angle at the time of the burn is %1.2f degrees\n',phase_angle);
  end

  if strcmp(target,'Yes')==0
    resonance=input('Are you puting up a comms network? ','s');
    if strcmp(resonance,'Yes')==1
      numsats=input('How many satelites are there? ');

      [r1,r2,altitudei,altitudef]=altitudes(Radius);

      period=(2*pi*sqrt(r2^3))/(sqrt(G*M));
      newr=2*(((((numsats-1)*period)/numsats)^2*G*M)/(4*pi^2))^(1/3)-r2;

      if newr-Radius(i)<=Atm(i)
        newr=2*(((((numsats+1)*period)/numsats)^2*G*M)/(4*pi^2))^(1/3)-r2;
        periapsis=newr-Radius(i);
        res_output(r1,r2,newr,altitudei,periapsis,altitudef,numsats);
      else
        periapsis=newr-Radius(i);
        res_output(r1,r2,newr,altitudei,periapsis,altitudef,numsats)
      end
    end
  end

  if strcmp(resonance,'Yes')==0 && strcmp(target,'Yes')==0

    [r1,r2,altitudei,altitudef]=altitudes(Radius);
    deltav=abs(Vellipse(r1,r2)-Vellipse(r1,r1));
    deltav2=abs(Vellipse(r2,r2)-Vellipse(r2,r1));

    clc;

    fprintf('The delta v required for a transfer to %1.2fm from %1.2fm is %1.2fm/s\n',altitudef,altitudei,deltav);
    fprintf('The delta v required to circularize into an orbit of altitude %1.2fm is %1.2fm/s\n',altitudef,deltav2)
  end

  answer=input('Do you wish to add another maneuver? ','s');
  if strcmp(answer,'Yes')==1
      answer=1;
  else
      answer=0;
  end
end

function [r1,r2,altitudei,altitudef]=altitudes(x)
  global i
  global Atm
  altitudei=input('State initial altitude: ');
  altitudef=input('State target altitude: ');
  while (altitudei<Atm(i) || altitudef<Atm(i))
    fprintf('Please choose orbital altitudes greater than %1.0fm\n',Atm(i));
    altitudei=input('State initial altitude: ');
    altitudef=input('State target altitude: ');
  end
  r1=x(i)+altitudei;
  r2=x(i)+altitudef;
end

function [v]=Vellipse(r,s)
  global M
  global G
  v=sqrt(((2*G*M)/r)-((G*M)/(.5*(r+s))));
end

function res_output(r1,r2,newr,altitudei,periapsis,altitudef,numsats)
  deltav=abs(Vellipse(r1,r2)-Vellipse(r1,r1));

  new_deltav=abs(Vellipse(r2,newr)-Vellipse(r2,r1));
  new_deltav2=abs(Vellipse(r2,r2)-Vellipse(r2,newr));
  apoapsis=altitudef;

  clc

  fprintf('To get %i comms sats to orbit of %1.2fm the resonance orbit will be %1.2fm by %1.2fm\n',numsats,altitudef,apoapsis,periapsis);
  fprintf('The delta v required for a transfer to %1.2fm from %1.2fm is %1.2fm/s\n',altitudef,altitudei,deltav);
  fprintf('The delta v required to transfer to resonance orbit is %1.2fm/s\n',new_deltav);
  fprintf('The delta v required to circularize into an orbit of altitude %1.2fm is %1.2fm/s\n',altitudef,new_deltav2);
end
