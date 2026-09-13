# Documentation de développement

Cet espace est la documentation technique versionnée de l'application compagnon **24**.

| Dossier | Contenu |
|---|---|
| `architecture/` | Architecture applicative et technique |
| `decisions/` | ADR et arbitrages |
| `specifications/` | Référence fonctionnelle et validation du POC |
| `mvp/` | Lots, backlog et critères d'acceptation |
| `ui-ux/` | Parcours, écrans et ergonomie |
| `testing/` | Stratégie et scénarios de tests |
| `operations/` | Build, distribution, publication, maintenance |

## Parcours de lecture et autorité

1. [APPLICATION_COMPAGNON.md](specifications/APPLICATION_COMPAGNON.md) : quoi/pourquoi fonctionnel, issu de la conception humaine.
2. [ADR](decisions/) : décisions explicitement ACTÉES.
3. [ARCHITECTURE.md](architecture/ARCHITECTURE.md) : cible technique recommandée/exploratoire.
4. [LOT0_POC.md](specifications/LOT0_POC.md) : conventions humaines propres au LOT 0, hypothèses et mesures.

Un ADR ACTÉ prévaut sur une recommandation contradictoire, y compris dans
`AGENTS.md`. Signaler les contradictions de même niveau. Une convention
**ACTÉE POUR LE LOT 0** ne devient pas une décision produit définitive.

La conception complète reste sur Google Drive, lié par `../conception` et
exclu de Git. La référence fonctionnelle locale suffit pour cette préparation ;
un manque métier réel doit être soumis à arbitrage humain, sans déduction
du contenu inaccessible des `.gdoc`/`.gsheet`.
