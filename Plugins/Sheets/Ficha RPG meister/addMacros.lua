--Add Macros code
local version = 1

local ataqText = [[
-- USO: /ataq <Nº do ataque> <Filtro>
-- /ataq ou /atq <numero (opcional) <filtro npc|pc|pcOnline|all|mine (opcional)>", descricao="Ficha Pathfinder. Ao usar /per (sem parametros) abre um popup para selecionar um ataque avançado. Será feito o ataque com o personagem mais recentemente atribuido. Ao usar /per acompanhado de um numero e sem um filtro, o ataque naquela posição será realizado. Ao usar /per acompanhado de um valor (use -1 se quiser selecionar o ataque na janela pop up) e um parametro de filtro é aberta uma janela para selecionar um personagem para realizar o ataque.
if parametro~="" and parametro~=nil and #arg==0 then
  --write("param != arg")
  --write(parametro)
  arg = {};
  local index = 0;
  for i in string.gmatch(parametro, "%S+") do
  	index = index + 1;
  	arg[index] = i;
  end
end
local indice = tonumber(arg[1])
local texto = ""
local filter = arg[2]
local personagem = sheet
if filter == "all" or filter == "pc" or filter == "pcOnline" or filter=="npc" then
  personagem = getCharacterSheet(chooseCharacter("Qual personagem deseja usar para atacar?", filter))
elseif filter == "mine" then
  personagem = getCharacterSheet(chooseCharacterOfPlayer("Qual personagem deseja usar para atacar?", myPlayer))
end

local ataques = ndb.getChildNodes(personagem.campoDosAtaques)
local lista = {}
for i=1, #ataques, 1 do
  lista[i] = ataques[i].nomeAtaque
end
if indice == nil or indice < 1 or indice > #ataques then
  indice, texto = choose("Que teste deseja fazer?", lista, 1)
end

local armas = ndb.getChildNodes(ataques[indice].campoDeArmas)
local acertos = {}
local danos = {}
local margens = {}
local decisivo = {}
local nomes = {}
local id = {}
local resultados = {}
local rolagem = {}
local index = 0
-- Preparando os ataques
for i=1, #armas, 1 do  local golpes = armas[i].acertos
  for j=1, armas[i].numAtaques, 1 do
    index = index + 1
    acertos[index] = golpes[j]
    danos[index] = armas[i].dado
    margens[index] = armas[i].decisivo
    decisivo[index] = armas[i].crit
    nomes[index] = armas[i].nomeAtaque or "arma"
    id[index] = j
  end
end
-- Rolando os ataques
for i=1, index, 1 do
  local teste = "1d20+".. acertos[i]
  resultados[i], rolagem[i] = rolar (teste, "Ataque#" .. id[i] .. " com " .. nomes[i] .. " de " .. (personagem.nome or "nome"))
end
-- Dano dos Ataques
for i=1, index, 1 do
  rolar (danos[i], "Dano#" .. id[i] .." com " .. nomes[i] .. " de " .. (personagem.nome or "nome"))
end
-- Rolando as Confirmações de criticos
for i=1, index, 1 do
  local dado = rolagem[i].ops[1].resultados[1]
  if dado>=margens[i] then
    local teste = "1d20+".. acertos[i]
    rolar (teste, "Confirmação de Decisivo#" .. id[i] .. " com " .. nomes[i] .. " de " .. (personagem.nome or "nome"))
  end
end
-- Dano dos criticos
for i=1, index, 1 do
  local dado = rolagem[i].ops[1].resultados[1]
  if dado>=margens[i] then
    local teste = "1d20+".. acertos[i]
    rolar (decisivo[i], "Dano extra de Decisivo#" .. id[i] .." com " .. nomes[i] .. " de " .. (personagem.nome or "nome"))
  end
end
]]

local perText = [[
-- USO: /per <Nome da Pericia> <Filtro>
-- /per <numero ou nome (opcional)> <filtro npc|pc|pcOnline|all|mine (opcional)>", descricao="Ficha Pathfinder. Ao usar /per (sem parametros) abre um popup para selecionar um teste de pericia. Será feito o teste de atributo do personagem mais recentemente atribuido. Ao usar /per acompanhado de um numero e sem um filtro o teste da pericia naquela posição da ficha será realizado. Ao usar /per acompanhado do nome da pericia o teste daquela pericia será realizado. Tente por o nome da pericia parecido com como está na ficha. O macro vai tentar ignorar letras maiusculas, acentos e outros. Ao usar /per acompanhado de um valor (numero ou nome, use -1 se quiser selecionar a pericia na janela pop up) e um parametro de filtro é aberta uma janela para selecionar um personagem para realizar o teste.
if parametro~="" and parametro~=nil and #arg==0 then
  --write("param != arg")
  --write(parametro)
  arg = {};
  local index = 0;
  for i in string.gmatch(parametro, "%S+") do
  	index = index + 1;
  	arg[index] = i;
  end
end
local indice = tonumber(arg[1])
local nome = parametro
local texto = ""

local filter = arg[#arg]
local personagem = sheet
if filter == "all" or filter == "pc" or filter == "pcOnline" or filter=="npc" or filter=="mine" then
  if filter=="mine"then
    personagem = getCharacterSheet(chooseCharacterOfPlayer("Qual personagem deseja usar para o teste?", myPlayer))
  else
    personagem = getCharacterSheet(chooseCharacter("Qual personagem deseja usar para o teste?", filter))
  end
  -- Atualizando o nome da pericia pra remover o filtro
  local size = #arg-1
  nome = ""
  for i=1, size, 1 do
    nome = nome .. arg[i]
    if i ~= size then
        nome = nome .. " "
    end
  end
end

local pericias = ndb.getChildNodes(personagem.campoDasPericias)
local lista = {}
for i=1, #pericias, 1 do
  lista[i] = pericias[i].nomePericia
  if utils.compareStringPtBr(lista[i], nome) == 0 then
    indice = i
  end
end

if indice == nil or indice < 1 or indice > #pericias then
  indice, texto = choose("Que teste deseja fazer?", lista, 1)
end

local teste = "1d20+"
teste = teste .. (tonumber(pericias[indice].totalPericia) or 0)
rolar(teste, "Teste de " .. lista[indice] .. " de " .. (personagem.nome or "Nome"))
]]

local atrText = [[
-- USO: /atr <Nº do atributo 1:6> <filtro>
-- /atr <numero 1 a 6 (opcional)> <filtro npc|pc|pcOnline|all|mine (opcional)>", descricao="Ficha Pathfinder. Ao usar /atr (sem parametros) abre um popup para selecionar um teste de resistencia. Será feito o teste de atributo do personagem mais recentemente atribuido. Ao usar /atr acompanhado de um numero e sem um filtro o teste de atributo (1: FOR, 2: DES, 3: CON, 4: INT, 5: SAB, 6:CAR) é feito para o personagem mais recentemente atribuido. Ao usar /atr acompanhado de um valor (use -1 se quiser selecionar o atributo na janela pop up) e um parametro de filtro é aberta uma janela para selecionar um personagem para realizar o teste.
if parametro~="" and parametro~=nil and #arg==0 then
  --write("param != arg")
  --write(parametro)
  arg = {};
  local index = 0;
  for i in string.gmatch(parametro, "%S+") do
  	index = index + 1;
  	arg[index] = i;
  end
end
local indice = tonumber(arg[1])
local texto = ""
local filter = arg[2]
local personagem = sheet

if filter == "all" or filter == "pc" or filter == "pcOnline" or filter=="npc" then
  personagem = getCharacterSheet(chooseCharacter("Qual personagem deseja usar?", filter))
elseif filter == "mine" then
  personagem = getCharacterSheet(chooseCharacterOfPlayer("Qual personagem deseja usar?", myPlayer))
end

if indice == nil or indice < 1 or indice > 6 then
  indice, texto = choose("Que teste deseja fazer?", {"Força", "Destreza", "Constituição", "Inteligência", "Sabedoria", "Carisma"}, 1)
end

local teste = "1d20+"
if indice == 1 then
  teste = teste .. (tonumber(personagem.efetModFor) or 0)
  rolar(teste, "Teste de Força de " .. (personagem.nome or "Nome"))
elseif indice == 2 then
  teste = teste .. (tonumber(personagem.efetModDes) or 0)
  rolar(teste, "Teste de Destreza de " .. (personagem.nome or "Nome"))
elseif indice == 3 then
  teste = teste .. (tonumber(personagem.efetModCon) or 0)
  rolar(teste, "Teste de Constituição de " .. (personagem.nome or "Nome"))
elseif indice == 4 then
  teste = teste .. (tonumber(personagem.efetModInt) or 0)
  rolar(teste, "Teste de Inteligência de " .. (personagem.nome or "Nome"))
elseif indice == 5 then
  teste = teste .. (tonumber(personagem.efetModSab) or 0)
  rolar(teste, "Teste de Sabedoria de " .. (personagem.nome or "Nome"))
elseif indice == 6 then
  teste = teste .. (tonumber(personagem.efetModCar) or 0)
  rolar(teste, "Teste de Carisma de " .. (personagem.nome or "Nome"))
end
]]

local trText = [[
-- USO: /tr <Nº do TR 1:3> <filtro>
-- /tr <numero 1 a 3 (opcional)> <filtro npc|pc|pcOnline|all|mine (opcional)>", descricao="Ficha Pathfinder. Ao usar /tr (sem parametros) abre um popup para selecionar um teste de resistencia. Será feito o teste de resistência do personagem mais recentemente atribuido. Ao usar /tr acompanhado de um numero e sem um filtro o teste de resistencia (1: fortitude, 2: reflexos, 3: vontade) é feito para o personagem mais recentemente atribuido. Ao usar /tr acompanhado de um valor (use -1 se quiser selecionar a resistencia na janela pop up) e um parametro de filtro é aberta uma janela para selecionar um personagem para realizar o teste.
if parametro~="" and parametro~=nil and #arg==0 then
  --write("param != arg")
  --write(parametro)
  arg = {};
  local index = 0;
  for i in string.gmatch(parametro, "%S+") do
  	index = index + 1;
  	arg[index] = i;
  end
end
local indice = tonumber(arg[1])
local texto = ""
local filter = arg[2]
local personagem = sheet

if filter == "all" or filter == "pc" or filter == "pcOnline" or filter=="npc" then  
  personagem = getCharacterSheet(chooseCharacter("Qual personagem deseja usar?", filter))
elseif filter == "mine" then  
  personagem = getCharacterSheet(chooseCharacterOfPlayer("Qual personagem deseja usar?", myPlayer))
end

if indice == nil or indice < 1 or indice > 3 then  
  indice, texto = choose("Que teste deseja fazer?", {"Fortitude", "Reflexos", "Vontade"}, 1)
end

local teste = "1d20+"
if indice == 1 then  
  teste = teste .. (tonumber(personagem.trFort) or 0)
  rolar(teste, "Teste de Fortitude de " .. (personagem.nome or "Nome"))
elseif indice == 2 then
  teste = teste .. (tonumber(personagem.trRef) or 0)
  rolar(teste, "Teste de Reflexos de " .. (personagem.nome or "Nome"))
elseif indice == 3 then
  teste = teste .. (tonumber(personagem.trVon) or 0)
  rolar(teste, "Teste de Vontade de " .. (personagem.nome or "Nome"))
end
]]

local iniText = [[
-- USO: /ini <filtro>
-- /ini <filtro npc|pc|pcOnline|all|mine (opcional)>", descricao="Ficha Pathfinder. Ao usar /ini (sem parametros) a iniciativa do personagem mais recentemente atribuido é rolada. Ao usar /per acompanhado de um filtro é aberta uma janela para selecionar um personagem para rolar a iniciativa.
if parametro~="" and parametro~=nil and #arg==0 then
  --write("param != arg")
  --write(parametro)
  arg = {};
  local index = 0;
  for i in string.gmatch(parametro, "%S+") do
  	index = index + 1;
  	arg[index] = i;
  end
end

local filter = arg[1]
local personagem = sheet

if filter == "all" or filter == "pc" or filter == "pcOnline" or filter=="npc" then  
  personagem = getCharacterSheet(chooseCharacter("Qual personagem deseja usar?", filter))
elseif filter == "mine" then  
  personagem = getCharacterSheet(chooseCharacterOfPlayer("Qual personagem deseja usar?", myPlayer))
end

local teste = "1d20+"
teste = teste .. (tonumber(personagem.iniciativa) or 0)
rolar(teste, "Iniciativa de " .. (personagem.nome or "Nome"))
]]

-- If using room ndb look for 'RRPG_Macros'
-- If using user ndb look for 'macros' [mesas/global]
local promise = Firecast.asyncOpenUserNDB("macros", {create=false})
local node = nil

local function AddMacro(nome,code)
  local macro = nil

  -- TRY TO FIND IF MACRO ALREADY EXISTS
  local macros = NDB.getChildNodes(node.global.macros)
  for i=1, #macros, 1 do 
    if macros[i].macro == nome then
      -- MACRO EXIST CHECK IF OLDER VERSION
      local currentVersion = tonumber(macros[i].version) or 0
      if version > currentVersion then
        -- THIS IS A NEWER VERSION, INSTALL
        macro = macros[i]
      else
        -- CANCEL MACRO UPDATE, OLDER VERSION
        return
      end
    end
  end

  -- MACRO DOESN'T EXISTS, CREATE NEW
  if macro == nil then
    macro = NDB.createChildNode(node.global.macros, "item")
  end

  -- ADD MACRO DETAILS
  macro.tipoMacro = "L"
  macro.macro = nome
  macro.version = version
  macro.acoes = code
end

promise:thenDo(
  function(userNDB)
    node = userNDB

    AddMacro("ataq", ataqText)
    AddMacro("atq", ataqText)
    AddMacro("per", perText)
    AddMacro("atr", atrText)
    AddMacro("tr", trText)
    AddMacro("ini", iniText)
  end);


