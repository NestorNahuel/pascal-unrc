Unit Menu;
Interface
  Const
    MaxOp= 10;                            // Maxima cantidad de opciones del menu
  Type
    TCadenas= Array[1..MaxOp] Of String;  // Opciones del menu
    TMenu= Record                         // Menu
      titulo: String;                     // Titulo del menu
      opcion: TCadenas;
      cant: Integer;                      // Cantidad de opciones del menu
    End;
  Function MostrarMenu(m: TMenu): Integer;
Implementation
  { Muestra el menu y devuelve el numero correspondiente a la opcion seleccionada }
  Uses
    Crt;
  Function MostrarMenu(m: TMenu): Integer;
  Var
    i,y: Integer;
    t: Char;
  Begin
    TextBackground(Black);
    ClrScr;
    i:= 1;
    y:= 2;
    Writeln(' ',m.titulo);
    While i<=m.cant Do Begin
      Writeln(' ',m.opcion[i]);
      i:= i+1;
    End;
    Gotoxy(1,20);
    Writeln('Use las teclas de desplazamiento (arriba y abajo)');
    Writeln('para moverse entre las opciones.');
    Writeln('Pulse la tecla enter para seleccionar la opcion marcada');
    Gotoxy(1,y);
    Repeat
      t:= Readkey;
      TextColor(White);
      Write(' ',m.opcion[y-1],'    ');
      Case t Of
        #72: y:= y-1;                     // Tecla Arriba
        #80: y:= y+1;                     // Tecla Abajo
      End;
      If (y>m.cant+1) 
      Then Begin
        y:= 2;   
      End;
      If (y<2)
      Then Begin
        y:= m.cant+1;   
      End;
      TextColor(Red);
      Gotoxy(1,y);
      Write(' -> ',m.opcion[y-1]);
      TextColor(White);
      Gotoxy(1,y);
    Until t= #13;                         // Tecla Enter
    Gotoxy(1,m.cant+2);  
    ClrScr;
    MostrarMenu:= y-1;
  End;
End.
