# WindowsConfigManager
Voltar ao menu de idiomas [aqui](./README.md).

## Descrição

Este projeto se concentra em fornecer uma maneira fácil de alterar as configurações do Windows. É um aplicativo projetado para ser executado constantemente, reconhecendo e aplicando configurações com base nas alterações feitas em um arquivo de configuração. De acordo com essas alterações, notificações push aparecem, notificando sobre novas configurações.

Este projeto será frequentemente atualizado com novos recursos.

## Instalação

1. Clone este repositório.
2. Execute o seguinte arquivo PowerShell com privilégios de administrador:

```powershell
WindowsConfigManager.ps1
```

## Uso

Para modificar as configurações do Windows com este aplicativo, altere o arquivo de configuração `UserConfig-WindowsConfigManager.ini` no diretório `config`.

Ex.:

Altere `deny` para `allow` em `task`:

Antes:

```ini
[Microphone]
Task = deny
Verbose = false
```

Depois:

```ini
[Microphone]
Task = allow
Verbose = false
```

Isso permitirá o uso do microfone na configuração de privacidade do Windows.

*Uma documentação completa de todas as possibilidades de uso estará disponível em breve.*

## Testes

Esta etapa ainda está em desenvolvimento.

## Contribuição

Sinta-se à vontade para contribuir com novas configurações ou corrigir bugs.

Se preferir, entre em contato comigo para discutir este projeto e novas alterações.
