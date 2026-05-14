% 1. Aggiunge la cartella esatta dove si nasconde LinearBankBehavior
javaaddpath(fullfile(pwd, 'java', 'src'));

% 2. Ricarica i jar di supporto
cartella_lib = fullfile(pwd, 'java', 'lib');
lista_jar = dir(fullfile(cartella_lib, '*.jar'));
for i = 1:length(lista_jar)
    javaaddpath(fullfile(cartella_lib, lista_jar(i).name));
end
disp('✅ MOTORE FINALE CARICATO CORRETTAMENTE! Ora premi Run.');