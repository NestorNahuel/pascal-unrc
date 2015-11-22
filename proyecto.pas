Program Proyecto;
Uses
  Crt, Menu;
Const
  MaxMesa= 4;                         // Maximo de mesas a cargar
Type

  TTelegrama= Record
    escuela, nroMesa: String;
    votosPartidoAzul, votosPartidoBlanco, votosPartidoColorado: Integer;
    votosAnulados, votosEnBlanco: Integer;
  End;

  TTele= Record
    telegrama: TTelegrama;  
    disponible: Boolean;                   // disponible logico
  End;

  TIndice= Record
    clave: String;                      // Numero de mesa
    pos: Integer;                       // Pos en archivo
  End;

  TArregloIndice= Array[1..MaxMesa] Of TIndice;

  TRegistroIndice= Record
    indice: TArregloIndice;   
    cant: Integer;                      // Cantidad de indices (mesas) cargados
  End;
  
  TArregloTeles= Array[1..MaxMesa] Of TTele;

  TRegistroTeles= Record
    teles: TArregloTeles;
    cant: Integer;
  End;
  
  TDobleteEscuela= Record
    info: TTele;
    next: ^TDobleteEscuela;
  End;
  
  TPuntero= ^TDobleteEscuela;
  
  TArchivoTeles= File Of TTele;         // Donde se almacenara las mesas cargadas
  
  TArchivoInd= File Of TRegistroIndice; // Donde se almacenara el indice

Var
  menuPrincipal : TMenu;                // Menu Principal
  menuActualizacion: TMenu;             // Menu de actualizacion y consulta
  archivoPrincipal: TArchivoTeles;      // Almacenara las mesas cargadas
  archivoIndice: TArchivoInd;           // Indice ordenado por numero de mesa residente en disco
  indice: TRegistroIndice;              // Indice ordenado por numero de mesa residente en memoria
  rpta: Integer;
  salida: Boolean;
{ Muestra el mensaje 'presione una tecla para continuar' }
Procedure Continuar;
Begin
  Writeln;
  Writeln('Presione una tecla para continuar');
  Readkey;
End;
{ Completa la cadena 'c' con ceros al principio }
Procedure PonerCeros(Var c: String);
Begin
  While Length(c)<4 Do Begin
    Insert ('0', c, 1);
  End;
End;
{ Devuelve la pos de la mesa en el archivo y si no la encuentra devuelve -1 }
Function BuscarMesa(numero: String; ind: TRegistroIndice): Integer; {ESQUEMA Busqueda dicotomica o binaria}
Var
  k, inf, sup: Integer;
  s: TArregloIndice;
begin
  s:= ind.indice;
  If ((numero<s[1].clave) Or (numero>s[ind.cant].clave))
  Then Begin
    BuscarMesa:= -1;
  End
  Else Begin
    inf:= 1;
    sup:= ind.cant;
    While inf<sup Do Begin
      k:= (inf+sup) Div 2;
      If numero>s[k].clave
      Then Begin
        inf:= k + 1;
      End
      Else Begin
        sup:= k;
      End;
    End;
    If numero=s[inf].clave
    Then Begin
      BuscarMesa:= s[inf].pos;
    End
    Else Begin
      BuscarMesa:= -1;
    End;
  End;
End;
{ Carga un registro del tipo TTelegrama controlando que no se ingrese un numero de mesa ya cargado }
Procedure CargarRegistro(Var reg: TTelegrama);
Begin
  Write('Nombre de la escuela:   ');
  Readln(reg.escuela);
  Write('Numero de mesa:         ');    
  Readln(reg.nroMesa);
  PonerCeros(reg.nroMesa);
  Write('Votos Partido Azul:     ');
  Readln(reg.votosPartidoAzul);
  Write('Votos Partido Blanco:   ');
  Readln(reg.votosPartidoBlanco);
  Write('Votos Partido Colorado: ');
  Readln(reg.votosPartidoColorado);
  Write('Votos En Blanco:        ');
  Readln(reg.votosEnBlanco);
  Write('Votos Anulados:         ');
  Readln(reg.votosAnulados);
End;
{ Muestra un registro del tipo de TTelegrama }
Procedure MostrarRegistro(reg: TTelegrama);
Begin
  Gotoxy(1,WhereY);
  Write(' ',reg.escuela,'   ');
  Gotoxy(11,WhereY);
  Write(' ',reg.nroMesa,'   ');
  Gotoxy(25,WhereY);
  Write(' ',reg.votosPartidoAzul,'   ');
  Gotoxy(35,WhereY);
  Write(' ',reg.votosPartidoBlanco,'   ');
  Gotoxy(47,WhereY);
  Write(' ',reg.votosPartidoColorado,'   ');
  Gotoxy(61,WhereY);
  Write(' ',reg.votosEnBlanco,'   ');
  Gotoxy(73,WhereY);
  Write(' ',reg.votosAnulados,'   ');
  Writeln;
End;
{ Carga un TRegistroIndice ordenado segun el numero de mesa de menor a mayor }
Procedure CrearIndice(Var arch: TArchivoTeles; Var ind: TRegistroIndice);
Var
  teles: TTele;
  aux: TIndice;
  i, j: Integer;
Begin
  {$I-}
  Reset(arch);
  {$I+}
  If IoResult=0 
  Then Begin
    { Carga del indice }
    If Filesize(arch)>MaxMesa
    Then Begin
      ind.cant:= MaxMesa;
    End
    Else Begin
      ind.cant:= Filesize(arch);
    End;
    i:= 0;
    While (Not EOF(arch)) And (i<ind.cant)  Do Begin
      Read(arch,teles);
      ind.indice[Filepos(arch)].clave:= teles.telegrama.nroMesa;
      ind.indice[Filepos(arch)].pos:= Filepos(arch)-1;
      i:= i+1;
    End;
    Close(arch);
    Writeln('Se cargaron ',ind.cant,' Mesas');
    { Ordenamiento del indice por insercion }
    i:= 2;
    While i <= ind.cant Do Begin
      aux:= ind.indice[i];
      j:= i-1;
      While (j>0) And (ind.indice[j].clave>aux.clave) Do Begin
        ind.indice[j+1]:= ind.indice[j];
        j:= j-1;
      End;
      ind.indice[j+1]:= aux;
      i:= i+1;
    End;
  End;
End;
{ Carga manualmente del archivo }
Procedure CrearArchivoInicial(Var arch: TArchivoTeles);
Var
  n: Integer;
  r: Char;
  aux,aux2: TTele;
  menu: TMenu;
  disponibles: Integer;
Begin
  {$I-}
  Reset(arch);
  {$I+}
  If IoResult=0
  Then Begin
    menu.titulo:= 'Ya hay mesas cargadas, Que desea hacer?';
    menu.cant:= 2;
    menu.opcion[1]:= 'Continuar cargando (Se conservaran las mesas cargadas)';
    menu.opcion[2]:= 'Eliminar mesas (Se eliminaran las mesas cargadas)';
    If MostrarMenu(menu)= 2
    Then Begin
      Rewrite(arch);
    End;
  End;
  Reset(arch);
  disponibles:= MaxMesa-Filesize(arch);
  If disponibles>0
  Then Begin
    Repeat
      Write('Mesas a cargar (Maximo ',disponibles,') : ');
      Readln(n);
      Clrscr
    Until n<=disponibles;
    While n>0 Do Begin
      Clrscr;
      CargarRegistro(aux.telegrama);
      aux.disponible:= True;
      Reset(arch);
      Case EOF(arch) Of
        True: Begin
                Write(arch,aux);
                n:= n-1;
              End;
        False:Begin
                Repeat
                  Read(arch,aux2);
                Until EOF(arch) Or (aux2.telegrama.nroMesa=aux.telegrama.nroMesa);
                Case aux2.telegrama.nroMesa=aux.telegrama.nroMesa Of
                  True: Begin
                          Write('La mesa ',aux2.telegrama.nroMesa,'Ya esta creada, desea sobreescribirla? S/N ');
                          Readln(r);
                          If (r='s') Or (r='S')
                          Then Begin
                            Seek(arch,Filepos(arch)-1);
                            Write(arch,aux);
                          End;
                        End;
                  False:Begin
                          Write(arch,aux);
                          n:= n-1;
                        End;
                End
              End;
      End;
    End;
  End
  Else Begin
    Writeln('Alcanzo el maximo de mesas a cargar (',MaxMesa,')');
  End;
  Close(arch);
End;
{ Agrega una nueva mesa en el archivo o lo sobreescribe si existe y esta elimindo }
Procedure CrearMesa(var arch:TArchivoTeles; ind:TRegistroIndice);
Var
  r: Char;
  aux, aux2: TTele;
  pos: Integer;
Begin
  {$I-}
  Reset(arch);
  {$I+}
  If IoResult<>0
  Then Begin
    Rewrite(arch);
  End;
  If Filesize(arch)<MaxMesa
  Then Begin
    CargarRegistro(aux.telegrama);
    aux.disponible:= true;
    r:= 's';
    pos:= BuscarMesa(aux.telegrama.nroMesa,ind);
    If Pos = -1
    Then Begin
      Seek(arch,Filesize(arch));
      Write(arch,aux);
    End
    Else Begin
      Seek(arch,pos);
      Read(arch,aux2);
      If aux2.disponible
      Then Begin
        Write('La mesa ya esta cargada, desea sobreescribirla? S/N');
        Readln(r);
        If (r='s') Or (r='S')
        Then Begin
          Seek(arch,pos);
          Write(arch,aux);
          Writeln('Mesa ',aux.telegrama.nroMesa,' Agregada');
        End;
      End;
    End;
  End
  Else Begin
    Writeln('Alcanzo el maximo de mesas a cargar (',MaxMesa,')');
  End;
  Close(arch);
End;
{ Guarda un TRegistroIndice en un archivo }
Procedure GuardarIndice(ind: TRegistroIndice; Var archInd: TArchivoInd);
Begin
  Rewrite(archInd);
  Write(archInd,ind);
  Close(archInd);
End;
{ Muestra los registros TTeles cargados en el archivo }
Procedure ListadoCronologico(Var arch: TArchivoTeles);
Var
  aux: TTele;
Begin
  {$I-}
  Reset(arch);
  {$I+}
  If IoResult=0 
  Then Begin
    Writeln('Escuela   Nro de mesa   P. Azul   P. Blanco   P. Colorado   En blanco   Anulados');
    While Not EOF(arch) Do Begin
      Read(arch,aux);
      If aux.disponible
      Then Begin
        MostrarRegistro(aux.telegrama);
      End;
    End;
    Close(arch);
  End
  Else Begin
    Writeln('No hay mesas cargadas')
  End;
End;
{ Muestra los registros TTeles segun el orden del indice - Marca Final}
Procedure ListadoClave(Var arch: TArchivoTeles; ind: TRegistroIndice);
Var
  aux: TTele;
  i: Integer;
Begin
  {$I-}
  Reset(arch);
  {$I+}
  If IoResult=0
  Then Begin
    i:=1;                                //Inicializacion de la adquisicion
    Writeln('Escuela   Nro de mesa   P. Azul   P. Blanco   P. Colorado   En blanco   Anulados');
    While i<=ind.cant Do Begin
      Seek(arch,ind.indice[i].pos);
      Read(arch,aux);
      If aux.disponible
      Then Begin                         //Tratamiento elemento corriente
        MostrarRegistro(aux.telegrama);
      End;
      i:= i+1;                           //Obtener siguiente elemento
    End;
    Close(arch);
  End
  Else Begin
    Writeln('No hay mesas cargadas')
  End;
End;
Procedure ListadoAlternativo(Var arch: TArchivoTeles);
Var
  aux: TTele;
  primero, punQ: TPuntero;
  Procedure Inicializar(Var punQ: TPuntero);
  Begin
    New(punQ);
    (punQ^).next:= Nil;
  End;
  Function Ultimo(punS: TPuntero): Boolean;
  Begin
    Ultimo:= (punS^).next= Nil;
  End;
  Procedure Avanzar(Var punS: TPuntero);
  Begin
    punS:= (punS^).next;
  End;
  Procedure Mostrar(punS: TPuntero);
  Var
    aux: TTele;
  Begin
    Writeln('Escuela   Nro de mesa   P. Azul   P. Blanco   P. Colorado   En blanco   Anulados');
    While Not Ultimo(punS) Do Begin
      Avanzar(punS);
      aux:= (punS^).info;
      MostrarRegistro(aux.telegrama)
    End;
  End;
  Procedure Insertar(nuevo: TTele;Var punQ: TPuntero);
  Var
    punR : TPuntero;
  Begin
    New(punR);
    (punR^).info:= nuevo;
    (punR^).next:= (punQ^).next;
    (punQ^).next:= punR;
  End;
Begin
  {$I-}
  Reset(arch);
  {$I+}
  If IoResult=0 
  Then Begin
    Inicializar(primero);
    While Not EOF(arch) Do Begin
      Read(arch,aux);
      If aux.disponible
      Then Begin
        punQ:= primero;
        While (((punQ^).info.telegrama.escuela <> aux.telegrama.escuela) And (Not Ultimo(punQ))) Do Begin
          Avanzar(punQ);
        End;
        Insertar(aux,punQ);
      End;
    End;
    mostrar(primero);
    Close(arch);
  End
  Else Begin
    Writeln('No hay mesas cargadas');
  End;
End;
{ Busca la mesa y la elimina logicamente }
Procedure Eliminar(ind: TRegistroIndice;Var arch: TArchivoTeles);
Var
  num: String;
  pos: Integer;
  aux: TTele;
Begin
  Write('Numero de mesa a eliminar: ');
  Readln(num);
  pos:= BuscarMesa(num,ind);
  Case pos Of
    -1: Writeln('No se encontro la mesa con el numero ',num);
  Else Begin
          Reset(arch);
          Seek(arch,pos);               // Posicion en el archivo donde se encuentra el registro buscado
          Read(arch,aux);
          Case aux.disponible Of
            True: Begin
                    aux.disponible:= False;       // disponible logico   
                    Seek(arch,pos);               // Posicion en el archivo donde se encuentra el registro buscado
                    Write(arch,aux);
                    Writeln('Mesa eliminada.');
                  End; 
            False:Writeln('La mesa ',num,' ya esta eliminada');
          End;
          Close(arch);
        End;
  End;
End;
{ Busca la mesa y la restaura logicamente }
Procedure Restaurar(ind: TRegistroIndice;Var arch: TArchivoTeles);
Var
  num: String;
  pos: Integer;
  aux: TTele;
Begin
  Write('Numero de mesa a restaurar: ');
  Readln(num);
  pos:= BuscarMesa(num,ind);
  Writeln(pos);
  Case pos Of
    -1: Writeln('No se encontro la mesa con el numero ',num);
  Else Begin
          Reset(arch);
          Seek(arch,pos);               // Posicion en el archivo donde se encuentra el registro buscado
          Read(arch,aux);
          Case Not aux.disponible Of
            True: Begin
                    aux.disponible:= True;       // disponible logico   
                    Seek(arch,pos);               // Posicion en el archivo donde se encuentra el registro buscado
                    Write(arch,aux);
                    Writeln('Mesa restaurada.');
                  End; 
            False:Writeln('La mesa ',num,' no esta eliminada');
          End;
          Close(arch);
        End;
  End;
End;
{ Busca un registro, lo muestra si existe y si no avisa }
Procedure BuscarRegistro(ind: TRegistroIndice; var arch: TArchivoTeles);
Var
  num: String;
  pos: Integer;
  aux: TTele;
Begin
  Write('Numero de mesa: ');
  Readln(num);
  pos:= BuscarMesa(num,ind);
  {$I-}
  Reset(arch);
  {$I+}
  If IoResult=0
  Then Begin  
    Case pos Of
      -1: Writeln('No se encontro la mesa con el numero ',num);
    Else Begin
            Seek(arch,pos);               // Posicion en el archivo donde se encuentra el registro buscado
            Read(arch,aux);
            If aux.disponible
            Then Begin
              Writeln('Escuela   Nro de mesa   P. Azul   P. Blanco   P. Colorado   En blanco   Anulados');
              MostrarRegistro(aux.telegrama);
            End
            Else Begin
              Writeln('La mesa ',num,' esta eliminada');
            End;
          End;
    End;
  End
  Else Begin
    Writeln('No hay mesas cargadas')
  End;
End;
{ Copia el registro TArchivoTeles en un arreglo TArregloTeles, calcula y muestra los datos pedidos }
Procedure Estadisticas(var arch: TArchivoTeles);
Var
  votosPAzul, votosPBlanco, votosPColorado, votosTMesa, total: Integer;
  reg: TRegistroTeles;
  aux: TTele;
  i, rpta: Integer;
  menuEstadistica: TMenu;               // Submenu en Estadisticas
  prom: Real;

  { Funcion recursiva que calcula el promedio de votos en blanco para todas mesas }
  Function Promedio(a: TArregloTeles; i, cant: Integer): Real;
  Begin
    Case i=0 Of
      True: Begin
              Promedio:= 0;
            End;
      False:Begin
              If a[i].disponible
              Then Begin
                Promedio:= a[i].telegrama.votosEnBlanco/cant + Promedio(a,(i-1),cant)
              End;
            End;
    End;
  End;
Begin
  {$I-}
  Reset(arch);
  {$I+}
  If IoResult=0
  Then Begin
    { Carga del arreglo - R1 marca inicial }
    While Not EOF(arch) Do Begin
      Read(arch,aux);                   // Obtener siguiente elemento
      reg.teles[Filepos(arch)]:= aux;   // Tratamiento del elemento corriente
    End;
    reg.cant:= Filesize(arch);
    Close(arch);
    { Carga de menu }
    menuEstadistica.titulo:= 'Estadisticas';
    menuEstadistica.cant:= 3;
    menuEstadistica.opcion[1]:= 'Total de votos por partido para todas las mesas';
    menuEstadistica.opcion[2]:= 'Total de votos por mesa (excluyendo los anulados)';
    menuEstadistica.opcion[3]:= 'Promedio de votos en blanco para todas las mesas';
    rpta:= MostrarMenu(menuEstadistica);
    Case rpta Of
      1:  Begin
            { Esquema R1 marca final }
            { Inicializacion de la adquisicion }
            i:= 1;
            { Inicializacion del tratamineto }
            votosPAzul:= 0;
            votosPBlanco:= 0;
            votosPColorado:= 0;
            While i<=reg.cant Do Begin
              If (reg.teles[i].disponible) 
              Then Begin
                { Tratamiento del elemento correinte }
                votosPAzul:= votosPAzul + reg.teles[i].telegrama.votosPartidoAzul;
                votosPBlanco:= votosPBlanco + reg.teles[i].telegrama.votosPartidoBlanco;
                votosPColorado:= votosPColorado + reg.teles[i].telegrama.votosPartidoColorado;
                { Obtener siguiente elemento }
              End;
              i:= i+1;
            End;
            { Tratamiento final }
            Writeln('Cantidad de votos Partido Azul: ',votosPAzul);
            Writeln('Cantidad de votos Partido Blanco: ',votosPBlanco);
            Writeln('Cantidad de votos Partido Colorado: ',votosPColorado);
            total:= votosPAzul+ votosPBlanco + votosPColorado;
            prom:= Promedio(reg.teles,reg.cant,total);
            Writeln('Promedio votos en Blanco: ',prom:2:6); 
          End;
      2:  Begin
            { Esquema R1 marca final }
            { Inicializacion de la adquisicion }
            i:= 1;
            While i<=reg.cant Do Begin
              { Tratamiento del elemento corriente }
              If (reg.teles[i].disponible) 
              Then Begin                
                votosTMesa:= reg.teles[i].telegrama.votosPartidoAzul + reg.teles[i].telegrama.votosPartidoBlanco + reg.teles[i].telegrama.votosPartidoColorado + reg.teles[i].telegrama.votosEnBlanco;
                Writeln('Mesa: ',reg.teles[i].telegrama.nroMesa,' Total de votos: ',votosTMesa);
              End;
              { Obtener siguiente elemento }
              i:= i+1;
            End;
          End;
      3:  Begin
            total:= 0;
            i:= 1;
            While i<=reg.cant Do Begin
              { Tratamiento del elemento corriente }
              If (reg.teles[i].disponible) 
              Then Begin
                votosTMesa:= reg.teles[i].telegrama.votosPartidoAzul + reg.teles[i].telegrama.votosPartidoBlanco + reg.teles[i].telegrama.votosPartidoColorado + reg.teles[i].telegrama.VotosAnulados;
                total:= total + votosTMesa;
              End;
              { Obtener siguiente elemento }
              i:= i+1;
            End;
            prom:= Promedio(reg.teles,reg.cant,total);
            Writeln('Promedio votos en Blanco: ',prom:2:6); 
          End;
    End;
  End
  Else Begin
    Writeln('No hay mesas cargadas');
  End;
End;
{ Elimina los registros TTeles eliminados logicamente haciendo uso de un archivo temporal }
Procedure Mantenimiento(Var arch: TArchivoTeles);
Var
  archAux: TArchivoTeles;
  aux: TTele;
  r: Char;
Begin
  Writeln('Ya no se podran restaurar las mesas eliminadas');
  Write('Desea realizar el mantenimiento? S/N ');
  Readln(r);
  If (r='s') Or (r='S')
  Then Begin
    {$I-}
    Reset(arch);
    {$I+}
    If IoResult=0
    Then Begin
      Assign(archAux,'temp.dat');           // Archivo temporal
      Rewrite(archAux);
      While Not EOF(arch) Do Begin
        Read(arch,aux);
        If  aux.disponible
        Then Begin
          Write(archAux,aux);
        End;
      End;  
      Rewrite(arch);                        // Vacia el archivo para volverlo a cargar
      Reset(archAux);
      While Not EOF(archAux) Do Begin
        Read(archAux,aux);
        If aux.disponible
        Then Begin
          Write(arch,aux);
        End;
      End;
      Close(archAux);
      Close(arch);
      Erase(archAux);                       // Elimina el archivo temporal
      Writeln('Mantenimiento realizado con exito');
    End
    Else Begin
      Writeln('No hay mesas cargadas');
    End;
  End
  Else Begin
    Writeln('No se realizo el mantenimiento');
  End;
End;

Procedure Salir(Var arch: TArchivoTeles; Var ind: TArchivoInd; indice: TRegistroIndice; Var salida: Boolean);
Var
  menu: TMenu;
Begin
  menu.titulo:= 'Que desea hacer?';
  menu.cant:= 3;
  menu.opcion[1]:= 'Salir conservando las mesas cargadas';
  menu.opcion[2]:= 'Salir y eliminar las mesas cargadas';
  menu.opcion[3]:= 'No salir, volver al menu anterior';
  Case MostrarMenu(menu) Of
    1:  Begin
          GuardarIndice(indice,archivoIndice);
          salida:= True;
        End;
    2:  Begin
          Erase(arch);
          Erase(ind);
          salida:= True;
        End;
    3: salida:= False;
  End;
End;

Begin
  { Carga del menu principal }
  menuPrincipal.titulo:= 'Menu principal';
  menuPrincipal.cant:= 3;
  menuPrincipal.opcion[1]:= 'Cargar N registros en el archivo "datosEleccion.dat"';
  menuPrincipal.opcion[2]:= 'Cargar el archivo "datosMuestra.dat"';
  menuPrincipal.opcion[3]:= 'Salir';
  { Carga del menu de acualizacion y consulta }
  menuActualizacion.titulo:= 'Menu de actualizacion y consulta';
  menuActualizacion.cant:= 10;
  menuActualizacion.opcion[1]:= 'Listado cronologico';
  menuActualizacion.opcion[2]:= 'Listado ordenado por Nro de mesa';
  menuActualizacion.opcion[3]:= 'Listado ordenado por escuela';
  menuActualizacion.opcion[4]:= 'Agregar registro';
  menuActualizacion.opcion[5]:= 'Buscar registro';
  menuActualizacion.opcion[6]:= 'Eliminar registro';
  menuActualizacion.opcion[7]:= 'Restaurar registro';
  menuActualizacion.opcion[8]:= 'Estadisticas';
  menuActualizacion.opcion[9]:= 'Mantenimiento';
  menuActualizacion.opcion[10]:= 'Salir';
  Assign(archivoIndice,'indice.dat');
  Case MostrarMenu(menuPrincipal) Of
    1:  Begin
          Assign(archivoPrincipal,'datosEleccion.dat');
          CrearArchivoInicial(archivoPrincipal);
          CrearIndice(archivoPrincipal,indice);
          GuardarIndice(indice,archivoIndice);
          Continuar;
        End;
    2:  Begin
          Assign(archivoPrincipal,'datosMuestra.dat');
          CrearIndice(archivoPrincipal,indice);
          GuardarIndice(indice,archivoIndice);
          Continuar;
        End;
    3:  Begin
          CrearIndice(archivoPrincipal,indice);
          GuardarIndice(indice,archivoIndice);
          Exit;
        End;
  End;
  salida:= False;
  Repeat
    rpta:= MostrarMenu(menuActualizacion);
    Case rpta Of
      1:  Begin
            ListadoCronologico(archivoPrincipal);
            Continuar;
          End;
      2:  Begin
            ListadoClave(archivoPrincipal,indice);
            Continuar;
          End;
      3:  Begin
            ListadoAlternativo(archivoPrincipal);
            Continuar;
          End;
      4:  Begin
            CrearMesa(archivoPrincipal,indice);
            CrearIndice(archivoPrincipal,indice);
            Continuar;
          End;
      5:  Begin
            BuscarRegistro(indice,archivoPrincipal);
            Continuar;
          End;
      6:  Begin
            Eliminar(indice,archivoPrincipal);
            Continuar;
          End;
      7:  Begin
            Restaurar(indice,archivoPrincipal);
            Continuar;
          End;
      8:  Begin
            Estadisticas(archivoPrincipal);
            Continuar;
          End;
      9:  Begin
            Mantenimiento(archivoPrincipal);
            CrearIndice(archivoPrincipal,indice);
            Continuar;
          End;
      10:  Begin
            Salir(archivoPrincipal,archivoIndice,indice,salida);
          End;
    End;
  Until salida;
End.
