**onFit - Acompanhamento de Treinos**

📌 Sobre o Projeto

O onFit é um aplicativo mobile desenvolvido em Flutter para ajudar usuários a acompanharem seus treinos e evolução física. O aplicativo permite cadastrar exercícios com carga, repetições e séries, armazenando os treinos por data. Além disso, o usuário pode acompanhar seu progresso por meio de gráficos de evolução de peso.

🚀 Funcionalidades

📅 Registro de Treinos: Permite adicionar exercícios com nome, carga, número de repetições e séries, associando-os a uma data.

📜 Histórico de Treinos: Visualização dos exercícios realizados em um calendário.

✏️ Edição e Exclusão de Exercícios: Gerencie seus treinos alterando ou removendo exercícios.

👤 Perfil do Usuário: Salve informações como nome, peso e objetivo.

📊 Gráfico de Evolução de Peso: Exibe a evolução do peso do usuário com base nas atualizações feitas no perfil.

🛠️ Tecnologias Utilizadas

Linguagem: Dart

Framework: Flutter

Banco de Dados: SQLite (armazenamento local)

Pacotes utilizados:

sqflite: Gerenciamento do banco de dados SQLite

path_provider: Acesso ao sistema de arquivos para armazenar o banco de dados

table_calendar: Exibição de calendário interativo

fl_chart: Geração de gráficos para análise da evolução

📲 Como Instalar e Executar

1️⃣ Pré-requisitos

Antes de iniciar, certifique-se de ter instalado:

Flutter

Android Studio ou VS Code com o plugin Flutter

Emulador Android ou dispositivo físico com depuração USB ativada

2️⃣ Clone o repositório

 git clone https://github.com/seu-usuario/onfit.git
 cd onfit

3️⃣ Instale as dependências

 flutter pub get

4️⃣ Execute o aplicativo

 flutter run

📷 Capturas de Tela

<img src="lib\assets\screenshots\onfitHomeScreen.png" alt="onfitHomeScreen" width="250" height="450"> 
<img src="lib\assets\screenshots\onfitAdicionarExercicio.png" alt="onfitAdicionarExercicio" width="250" height="450"> 
<img src="lib\assets\screenshots\onfitHistorico.png" alt="onfitHistorico" width="250" height="450"> 
<img src="lib\assets\screenshots\onfitPerfil.png" alt="onfitPerfil" width="250" height="450"> 
<img src="lib\assets\screenshots\onfitEvolucaoPeso.png" alt="onfitEvolucaoPeso" width="250" height="450"> 


📖 Estrutura do Projeto
```json
lib/
│-- main.dart            # Arquivo principal do app
│-- database_helper.dart # Gerenciamento do banco de dados SQLite
│-- home_screen.dart     # Tela inicial com menu principal
│-- add_exercise.dart    # Tela para adicionar exercícios
│-- history_screen.dart  # Tela com histórico de treinos e calendário
│-- profile_screen.dart  # Tela de perfil do usuário
```
🔥 Melhorias Futuras

📢 Notificações para lembrar os treinos

⏳ Temporizador para descanso entre séries

⏳ Sincronizar contador de calorias com o smartwatch

🌐 Sincronização na nuvem

🎯 Sugestões de treinos personalizadas

🤝 Contribuindo

Contribuições são bem-vindas! Para contribuir:

Faça um fork do projeto

Crie uma branch com a nova funcionalidade (git checkout -b minha-feature)

Commit suas mudanças (git commit -m 'Adicionei tal funcionalidade')

Envie para o repositório remoto (git push origin minha-feature)

Abra um Pull Request