# wslinit
Démaarage de daemons Linux WSL

Les daemon linux ne sont pas démarrer au démarrage de l’ordinateur.
Ils ne le sont pas non plus à l’ouverture de session.

La seule solution que j’ai trouvée, est de les démarrer à partir d’un batch.
Mais, ce batch ne peut etre exécuté avec la session de l’utilisateur fermé.

La couche WSL n’est démarrable qu’une fois une session utilisateur ouverte.
Donc, il faut que la session Windows s’ouvre seul.

Ce n’est pas un problème mais c’est dommage (je n’aime pas cette façon de faire).
la solution est de planifié le batch à l’ouverture de session
et de mettre en autologon la session de l'utilisateur qui a l'instance WSL Linux.
