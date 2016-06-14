# MarketNote
IOS App which helps in the expenses management 





Progetto di Laboratorio di Applicazioni Mobili


# MarketNote
_di Riccardo Sibani_




#Scopo dell’Applicazione

Controllo di spesa mensile/annuale: l'applicazione deve prevedere di poter inserire le spese sostenute durante la giornata, suddividendole secondo categorie (spesa domestica, pasti, mobilitá casa, bollette, ecc.) e produrre un rendiconto settimanale/mensile/annuale delle spese con un grafico e una media delle spese giornaliere/settimanali/annuali. 
Devono essere previste le opportune modalitá di navigazione tra le viste e la gesione del DB di spese protetto con password di accesso attraverso login su Database.





#Funzionalità Previste

Login dell’utente
Mostrare gli acquisti effettuati
Possibilità di aggiungere acquisti
Possibilità di modificare gli acquisti esistenti
Limite di un budget mensile (monthly ceiling)
Mostrare le statistiche per settimana, mese, anno
Schermata home con il riassunto delle spese del  mese corrente.




#Caratteristiche e Requisiti

L’applicazione funziona in ambiente iOS 9.0 sia su hardware iPad che iPhone e, grazie alle scrollview, non dovrebbe dare problemi con schermi di differenti dimensione. Devices testati: iPad Air 2, iPhone 6/6s, iPhone 6 plus/6s plus e iPhone 5s [ gira in linea teorica sull’80,7% degli iPhone] [fonte]( http://bgr.com/2016/02/06/most-popular-iphone-models/).





#Progettazione 
Per il lato server si è utilizzato Parse.

##View 

L’applicazione è divisa in 4 tab (Sum Up, Records, Statistics, Settings); la view è stata creata attraverso XCode e solo saltuariamente rimaneggia in codice. Il file in carico della view è Main.Storyboard.


##Controller
###Sum up
Fornisce una situazione riassuntiva del mese corrente con informazioni quali una barra che indica la percentuale del budget mensile utilizzato, il totale del mese corrente ed una tabella con le spese totali divise per categoria.

Il login è gestito dalla view Sum Up in quanto è la prima vista che l’applicazione carica. La registrazione e l’autenticazione è effettuata attraverso la libreria di Parse in quanto si voleva dare una dimostrazione della capacità e versatilità di Swift. Un login è tuttavia stato implementato dallo studente in un’altra applicazione (nel caso se ne vogliano valutare le capacità).
La view reinderizza a LoginSignUpViewController tramite un segue, il check viene fatto in viewDidLoad.

SumUpViewController si incarica nel metodo ViewDidAppear di modificare appropriatamente tutte le labels e di fare le richieste dovute alle classi DateUtils, Expense, Category per elaborare rispettivamente le date i periodi (Stringhe o NSDate), la liste delle expenses e le categorie da Parse. Queste due ultime classi portano ad una implementazione delle closures in quanto hanno metodi asincroni al proprio interno.

La View Sum Up implementa anche i protocolli UITableViewDataSource e UITableViewDelegate in quanto vi è una tabella all’interno che mostra il totale speso nel mese corrente per ogni categoria.

###Settings
Il controller SettingsViewController non ha troppe informazioni, semplicemente legge il budget mensile dell’user e ne permette la modifica attraverso il pulsante update. Ovviamente quando l’evento di update viene attivato, il dato verrà salvato in remoto nel database di Parse.


###ManageExpense

ManageExpenseViewController è una view che viene attivata da due controller: SumUpViewController e StatisticsViewController, ognuna con due propositi diversi. La prima vuole creare un nuovo evento, mentre la seconda popola la view con i dati di una expense che viene allegata al segue (sender). Viene implementato il protocollo UIPickerViewDataSource, UIPickerViewDelegate e UITextFieldDelegate.
Nel metodo viewDidLoad viene caricata la shortcut per il 3d touch, e si assegna il controller stesso al categoryPicker (PickerView che mostra le categorie) e alla tastiera.
Se c’è un oggetto selectedExpense (passato attraverso il segue), si setta il bottone con titolo “update” (anzichè del predefinito “Add”) e si popola la view con i relativi dati.

Ci sono metodi per gestire gli input, in risalto la funzione “textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool” in cui si filtra ogni input mandato dalla tastiera al campo amountTextField e lo si parsa e analizza in modo da garantire una indentazione euro friendly.

Vengono utilizzate le classi Category, currencyUtils


###Statistics

StatisticsViewController utilizza la libreria Charts (opportunamente importata) per creare i grafici barChartView e pieChartView. Il funzionamento è idealmente simile a quello di una tableView in quanto, allo stesso modo, si implementa il protocollo ChartViewDelegate.
Quando la view appare il controller chiede alla classe Expense tutte le statistiche poi le filtra in base ai parametri selezionati dall’utente nel segmentedControl. Il funzionamento è semplice, dopo aver filtrato i dati tramite le classi di supporto presenti nel model, il metodo setChart e setPieChart ricaricano le due viste a cui sono delegati i due chart.



###ExpensesListTableViewController & ExpensesListTableViewCell

Mentre ExpensesListTableViewCell è una semplice cell che riunisce i parametri che andranno settati in ogni riga della tabella, ExpensesListTableViewController si occupa di renderizzare la tabella (che occupa l’intera vista).
Prese le expenses dal database, si raggruppano per data (section) e si inserisce ogni record (row).
Quando si tappa su una riga, tramite il metodo func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) si rimanda ad un segue che aprirà la view ManageExpense che ne permetterà la modifica.
È inoltre implementato il 3D touch con peek and pop per la linea del record e la possibilità di eliminare la spesa nell “vista” peek.
Per cancellare una spesa (nel caso non sia disponibile il 3D Touch e non) si può effettuare uno swipe a sinistra e cancellare attraverso la linguetta rossa che verrà visualizzata.


##Model

###Expense

Questa classe si occupa di gestire i metodi per la creazione e gestione delle spese.
fetchExpenses (prende tutte le expenses)
fetchExpensesGreaterThenGivenPeriod (ritorna le expenses successive ad una data)
getCurrentMonthExpenses (ritorna le spese del mese corrente)
filterBy (filtra le expenes per giorno)
filterByMonth (filtra le expenses per mese)
getRange (ritorna una data di inizio ultimo periodo)
filterByCategory (filtra le expenses per categoria)
getExpensesAfterDate (ritorna le expenses dopo un certo periodo)
getExpensesByDate (calcola il totale di expenses per giorno)
getExpensesByDateMonth (calcola il totale di expenses per mese)

###DateUtils 
Questa classe si occupa di gestire i metodi per la gestione delle date.
getStringCurrentMonth (restituisce una string con mese corrente e anno)
getStartOfMonthDate (ritorna la data dell’inizio del mese)


###Category 
Questa classe si occupa di gestire i metodi per la creazione e la gestione delle spese
getCategories (ritorna tutte le categorie [closure])
filterByCategory (filtra le expenses per categoria)

###CurrencyUtils
Questa classe si occupa di gestire i metodi per mostrare il totale indentato in ManageExpenseViewController.
formatCurrency (formatta il totale da double a stringa senza virgole in base al nuovo carattere ricevuto)
fromStringToNumber (da stringa senza virgola ritorna il valore in double)
setPriceInTable (formatta il dato in database [double] in valore senza virgola e mettendo zeri a destra [double*100])



#Progettazione e Scelte Implementative

Per la progettazione ho deciso di utilizzare il paradigma MVC come è prassi per la programmazione in Swift.
Per la persistenza ho importato e utilizzato Parse perché molto usato in ambiente mobile, perché era una tecnologia con cui già avevo dimestichezza e non richiedeva l’implementazione di un server e un database (che sarebbe stato fuori dagli obiettivi del corso).
In futuro si potrebbe cambiare la parte di server e database ed utilizzare firebase o creare un server con Parse (ora diventato opensource).


#Difficolta’, Soluzioni e Aspetti Rilevanti per lo Sviluppo

Difficoltà sono state trovate all’inizio, Swift essendo un linguaggio nuovo e particolare e dal momento che, per sviluppare il progetto, ho programmato il codice durante il corso modificandolo più e più volte in base a cosa imparavo ad ogni lezione.

La difficoltà maggiore è stato invece l’utilizzo di Parse e, quindi, di richieste asincrone che ho dovuto approfondire in modo da rendere il codice più elegante, pulito ed ordinato. 


#Casi d’Uso

L’unica figura all’interno dell’applicazione è il singolo user
Aggiunta di una spesa
Visualizzazione di tutte le spese
Modifica di una spesa
Consultare le statistiche per settimana, mese e anno e per categoria.
Visualizzare una barra con la percentuale delle spese nel mese corrente
Settare un tetto mensile
Visualizzare un quadro riassuntivo del mese corrente


#Idee per Estensioni

Come estensione mi piacerebbe offrire la possibilità di aggiungere una fotografia ad ogni expense (per esempio uno scontrino). Ritengo sia una feature utile e di cui ho sentito il bisogno durante il mio periodo di testing. 
In futuro si potrebbe cambiare la parte di server e database ed utilizzare firebase o creare un server con Parse (ora diventato opensource)


#Conclusioni e Commenti Finali

Il progetto è stato davvero stimolante ed imparare un linguaggio come Swift ritengo sia fondamentale per il mio corso di Informatica per il Management.
Come commento personale esprimo il peccato di un tale esame all’ultimo semestre del terzo anno in quanto chi ha esigenza di laurearsi non ha tempo per sviluppare una propria applicazione estesa e piena di funzionalità a cause dei ridotti tempi a disposizione per l’ultima sessione.

___
#Appendice

##Screen Shots

![alt text](https://github.com/pinair/MarketNote/blob/master/img/IMG_2016-06-13%2020:43:43.jpg "Launch.storyboard")
![alt text](https://github.com/pinair/MarketNote/blob/master/img/IMG_2016-06-13%2020:43:38.jpg "Application Launch")
![alt text](https://github.com/pinair/MarketNote/blob/master/img/IMG_2016-06-13%2020:43:32.jpg "3D Touch Manage Expense")
![alt text](https://github.com/pinair/MarketNote/blob/master/img/IMG_2016-06-13%2020:43:47.jpg "Statistics")
