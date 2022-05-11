unit uShortcutsConsts;

interface

uses uShortcutsTypes;

const
  PREFIXO_ITEM_NAME = 'Item_';
  PREFIXO_ITEM_DEFAULT = 'mnu_';
  IMAGE_INDEX_NONE = -1;
  IMAGE_INDEX_APP = 0;
  IMAGE_INDEX_FECHAR = 1;
  IMAGE_INDEX_URL = 2;
  IMAGE_INDEX_FILE = 3;
  IMAGE_INDEX_EXE = 4;
  IMAGE_INDEX_REFRESH = 5;
  IMAGE_INDEX_TEXT = 6;
  ITEM_MENU_SEP = '-';
  NAME_DEFAULT  = 'DEFAULT';
  ICONS_PATH = './icons/';
  GOOGLE_FAVICON_URL = 'https://www.google.com/s2/favicons?domain_url=';

  ITEM_MENU_EDITAR = 'Editar Lista...';
  ITEM_MENU_ATUALIZAR = 'Atualizar';
  ITEM_MENU_FECHAR = 'Fechar';

  ArrayTipoItemMenuImageIndex: array[TTipoItemMenu] of Integer = (IMAGE_INDEX_NONE, IMAGE_INDEX_URL, IMAGE_INDEX_FILE, IMAGE_INDEX_EXE, IMAGE_INDEX_TEXT);
  ArrayItemMenuDefault: array[TTipoItemMenuDefault] of string = ('', ITEM_MENU_EDITAR, ITEM_MENU_ATUALIZAR, ITEM_MENU_FECHAR);
  ArrayItemMenuDefaultImageIndex: array[TTipoItemMenuDefault] of Integer = (IMAGE_INDEX_NONE, IMAGE_INDEX_TEXT, IMAGE_INDEX_REFRESH, IMAGE_INDEX_FECHAR);

implementation

end.
