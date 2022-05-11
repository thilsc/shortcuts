unit uShortcutsTypes;

interface

uses
  System.Classes;

type
  TTipoItemMenu = (timNone, timURL, timFile, timExe, timText);

  TTipoItemMenuDefault = (timdNone, timdEditar, timdAtualizar, timdFechar);

  TArrayDefaultEvents = array[TTipoItemMenuDefault] of TNotifyEvent;

  TArrayString = array of string;

implementation

end.
