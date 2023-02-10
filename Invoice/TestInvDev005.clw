

   MEMBER('TestInvDev.clw')                                ! This is a MEMBER module

                     MAP
                       INCLUDE('TESTINVDEV005.INC'),ONCE        !Local module procedure declarations
                     END


!!! <summary>
!!! Generated from procedure template - Source
!!! </summary>
RandomizeRandoms     PROCEDURE                             ! Declare Procedure
R LONG
M LONG 

  CODE
   M=RANDOM(100,300)
   LOOP CLOCK() TIMES
        R=RANDOM(1,M) 
   END
   RETURN 
!!! <summary>
!!! Generated from procedure template - Source
!!! </summary>
SmashSpaces          PROCEDURE  (*string Txt)              ! Declare Procedure
LenTxt  long,AUTO
InX     long,AUTO
OtX     long,AUTO

  CODE
    LenTxt = LEN(CLIP(Txt))
    IF ~LenTxt THEN RETURN.
    OtX = 0
    LOOP InX= 1 TO LenTxt
         CASE val(Txt[InX])
         OF 0 TO 32                             !just kill all low ASCII its bad news
            !OF 32 OROF 9 OROF 11 OROF 10 OROF 13       !Space,Tab,11,CR,LF
            !OROF 11 OROF 12                            !I use that in some things, 12=formfeed
         OF   160                                   !HardSpace=160=A0h
         OROF 129                                   !paste 13,10 can put 81h 129s
         ELSE
            OtX += 1
            IF Otx < InX THEN
               Txt[OtX] = Txt[InX]
            END
         END
    END
    IF OtX < LenTxt THEN Txt[ OtX+1 : LenTxt]=''.   !blank out stuff at end
    RETURN
!!! <summary>
!!! Generated from procedure template - Source
!!! </summary>
TestDataAddress      PROCEDURE  (*STRING outStreet,*STRING outCity,*STRING outState,*STRING outZip,BOOL ZipPlus4) ! Declare Procedure

  CODE
    outStreet       = RANDOM(10,9999) &' '& TestDataLorem( RANDOM(12,20) ) & |      !?  TestDataWord() 
                        ' '& CHOOSE(RANDOM(1,15), 'Road','Street','Way','Avenue','Drive','Lane','Court','Hwy','Blvd','Pkwy','Court','Trail','','','' ) & |
                      CHOOSE(RANDOM(1,5),'<13,10>PO Box '& RANDOM(50,999),'' )      !1 out of 5 have PO Box 
!    outCity         = TestDataLorem( RANDOM(12,20) )
    outCity         = TestDataWord()
    IF LEN(CLIP(outCity)) < 7 THEN 
       outCity = CLIP(outCity) & lower(TestDataWord())  
    END 
    TestDataStateCode(outState,outZip,ZipPlus4)          
    RETURN 
!!! <summary>
!!! Generated from procedure template - Source
!!! </summary>
TestDataFirstLast    PROCEDURE  (*STRING FName,*STRING LName) ! Declare Procedure
Cnt255  BYTE,STATIC 

  CODE
    FName = TestDataWord()              !Todo consider instend of random Increment thru the word list by passing an index 
    LName = TestDataWord() 
     
    Cnt255 += 1
    CASE Cnt255
    OF 11   ; LName='O''' & LName
    OF 31   ; LName=CHOOSE(RANDOM(1,2),'Mac ','Mc ') & LName
    OF 61   ; LName=CLIP(LName) & 'sen'
    OF 91   ; LName='Le ' & LName
    OF 111  ; LName='De ' & LName
    OF 131  ; LName=CHOOSE(RANDOM(1,4),'van de ','ven der ','ven den ','van ') & LName
    END 
    !???: Di+ Du+ La+ Von+  Fitz+
    RETURN 
!!! <summary>
!!! Generated from procedure template - Source
!!! </summary>
TestDataLorem        PROCEDURE  (USHORT Bytes2Return=30)   ! Declare Procedure
Latin STRING('Lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod tempor incididunt ' &| !   http://www.thelatinlibrary.com/cic.html
     'ut labore et dolore magna aliqua Ut enim ad minim veniam quis nostrud exercitation ullamco ' &|
     'laboris nisi ut aliquip ex ea commodo consequat Duis aute irure dolor in reprehenderit ' &|
     'in voluptate velit esse cillum dolore eu fugiat nulla pariatur Excepteur sint occaecat ' &|
     'cupidatat non proident sunt in culpa qui officia deserunt mollit anim id est laborum ' &|
     'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque ' &|
     'laudantium totam rem aperiam eaque ipsa quae ab illo inventore veritatis et quasi architecto ' &|
     'beatae vitae dicta sunt explicabo Nemo enim ipsam voluptatem quia voluptas sit aspernatur ' &|
     'aut odit aut fugit sed quia consequuntur magni dolores eos qui ratione voluptatem sequi ' &|
     'nesciunt Neque porro quisquam est qui dolorem ipsum quia dolor sit amet consectetur ' &|
     'adipisci velit sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam ' &|
     'aliquam quaerat voluptatem Ut enim ad minima veniam quis nostrum exercitationem ullam ' &|
     'corporis suscipit laboriosam nisi ut aliquid ex ea commodi consequatur Quis autem vel ' &|
     'eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur ' &|
     'vel illum qui dolorem eum fugiat quo voluptas nulla pariatur At vero eos et accusamus ' &|
     'et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque ' &|
     'corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident ' &|
     'similique sunt in culpa qui officia deserunt mollitia animi id est laborum et dolorum ' &|
     'fuga Et harum quidem rerum facilis est et expedita distinctio Nam libero tempore cum ' &|
     'soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat ' &|
     'facere possimus omnis voluptas assumenda est omnis dolor repellendus Temporibus autem ' &|
     'quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates ' &|
     'repudiandae sint et molestiae non recusandae Itaque earum rerum hic tenetur a sapiente ' &|
     'delectus ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus ' &|
     'asperiores repellat Quae res in civitate duae plurimum possunt eae contra nos ambae ' &|
     'faciunt in hoc tempore summa gratia et eloquentia quarum alterum Aquili vereor ' &|
     'alteram metuo Eloquentia Hortensi ne me in dicendo impediat non nihil commoveor ' &|
     'gratia Naevi ne Quinctio noceat id vero non mediocriter pertimesco Neque hoc ' &|
     'tanto opere querendum videretur haec summa in illis esse si in nobis essent saltem mediocria' &|
     ' verum ita se res habet ut ego qui neque usu satis et ingenio parum possum cum patrono ' &|
     'disertissimo comparer Quinctius cui tenues opes nullae facultates exiguae amicorum ' &|
     'copiae sunt cum adversario gratiosissimo contendat Illud quoque nobis accedit incommodum ' &|
     'quod M Iunius qui hanc causam aliquotiens apud te egit homo et in aliis causis exercitatus ' &|
     'et in hac multum ac saepe versatus hoc tempore abest nova legatione impeditus et ad ' &|
     'me ventum est qui ut summa haberem cetera temporis quidem certe vix satis habui ut rem ' &|
     'tantam tot controversiis implicatam possem cognoscere Ita quod mihi consuevit in ceteris ' &|
     'causis esse adiumento id quoque in hac causa deficit Nam quod ingenio minus possum ' &|
     'subsidium mihi diligentia comparavi quae quanta sit nisi tempus et spatium datum sit ' &|
     'intellegi non potest Quae quo plura sunt aquili eo te et hos qui tibi in consilio ' &|
     'sunt meliore mente nostra verba audire oportebit ut multis incommodis veritas debilitata ' &|
     'tandem aequitate talium virorum recreetur Quod si tu iudex nullo praesidio fuisse videbere ' &|
     'contra vim et gratiam solitudini atque inopiae si apud hoc consilium ex opibus non ex ' &|
     'veritate causa pendetur profecto nihil est iam sanctum atque sincerum in civitate nihil ' &|
     'est quod humilitatem cuiusquam gravitas et virtus iudicis consoletur Certe aut apud te ' &|
     'et hos qui tibi adsunt veritas valebit aut ex hoc loco repulsa vi et gratia locum ubi ' &|
     'consistat reperire non poterit Eos porro qui defendere consuerunt vides accusare in ' &|
     'ingenia conuerti perniciem antea versabantur in salute atque auxilio ferendo ' ),STATIC ! Length = 4039 maybe less
Str         STRING(2048)AUTO 
MaxRandom   LONG
RandPos     LONG
!SpacePos    LONG

  CODE
    IF Bytes2Return=0 THEN Bytes2Return=30.
    IF Bytes2Return>SIZE(Str) THEN Bytes2Return=SIZE(Str).
    MaxRandom = SIZE(Latin) - Bytes2Return*2 - 10 
    RandPos=RANDOM(1,MaxRandom)

    Str=LEFT(Latin[RandPos + 1 : RandPos + Bytes2Return + 20])
    IF ~Str[2] THEN     !1 letter + space
        Str=LEFT(Str[3 : 3+ Bytes2Return +2 ])
    END 
    Str[1]=UPPER(Str[1])
    RETURN CLIP(Str[1 : Bytes2Return]) !&' '& RandPos

    !Below tries to find the Space to get better first Word, but that limits the return to far fewere.    

!    SpacePos=INSTRING(' ',Latin[RandPos : RandPos + Bytes2Return*2],1) + RandPos - 1
!    Str=LEFT(Latin[SpacePos + 1 : SpacePos + Bytes2Return + 2])
!    Str[1]=UPPER(Str[1])
!    RETURN Str[1 : Bytes2Return] &' '& RandPos &' '& SpacePos
!!! <summary>
!!! Generated from procedure template - Source
!!! </summary>
TestDataPhone        PROCEDURE  ()                         ! Declare Procedure
ST_Area STRING('AL205 AR501 AZ602 CA213 CA415 CA916 CO303 CT203 DC202 DE302 FL305 GA404 IA319 IA515 IA712 ID208 ' & |
               'IL217 IL312 IL618 IL815 IN317 IN812 KS316 KS913 KY502 LA504 MA413 MA617 MD301 ME207 MI313 MI517 ' & |
               'MI616 MN218 MN612 MO314 MO816 MS601 MT406 NC704 ND701 NE402 NH603 NJ201 NM505 NV702 NY212 NY315 ' & |
               'NY518 NY716 NY914 OH216 OH419 OH513 OH614 OK405 OR503 PA215 PA412 PA717 PA814 RI401 SC803 SD605 ' & |
               'TN901 TX214 TX512 TX713 TX915 UT801 VA703 VT802 WA206 WI414 WI715 WV304 WY307 '),STATIC 

!Above the original North America Area Code plan from 1947: https://en.wikipedia.org/wiki/Original_North_American_area_codes

ACRand  SHORT,AUTO      

!AllAreaNow STRING('20120220320420520620720820921021221321421521621721821922422522622822923123423924024224624825025125225325' &|
!     '4256260262264267268269270276281284289301302303304305306307308309310312313314315316317318319320321323325330' &|
!     '3343363373393403453473513523603613864014024034044054064074084094104124134144154164174184194234244254304324' &|
!     '3443543844044144345045646947347847948048450050150250350450550650750850951051251351451551651751851952053054' &|
!     '0541551559561562563567570571573574580585586600601602603604605606607608609610612613614615616617618619620623' &|
!     '6266306316366416466476496506516606616626646706716786826847007017027037047057067077087097107127137147157167' &|
!     '1771871972072472773173273474075475775876076276376576776977077277377477577878078178478578678780080180280380' &|
!     '4805806807808809810812813814815816817818819828829830831832843845847848850856857858859860862863864865866867' &|
!     '8688698708768778788889009019029039049059069079089099109129139149159169179189199209259289319369379399409419' &|
!     '47949951952954956970971972973978979980985989' ),STATIC   ! Length = 996

  CODE
    ACRand = RANDOM(0,SIZE(ST_Area)/6-1) * 6 + 1       !e.g. 'AL205 AR501 AZ602 CA213 CA415 CA916 CO303 
    
    RETURN SUB(ST_Area,ACRand+2,3) & |  
           '-' & FORMAT(Random(201,999),@n03) & | 
           '-' & FORMAT(Random(0,9999),@n04) 

!
!    ACRand = RANDOM(0,SIZE(Area)/3-1) * 3 + 1
!    RETURN SUB(Area,ACRand,3) & |                       !RANDOM(201,796) & |
!           '-' & FORMAT(Random(201,999),@n03) & | 
!           '-' & FORMAT(Random(0,9999),@n04) 
!!! <summary>
!!! Generated from procedure template - Source
!!! </summary>
TestDataStateCode    PROCEDURE  (*STRING outState,<*STRING outZip>,BOOL ZipPlus4) ! Declare Procedure
States STRING('AK AL AR AZ CA CO CT DC DE FL GA HI IA ID IL IN KS KY LA MA MD ME MI MN MS MT NC ND NE NH NJ NM NV NY OH OK OR PA PR RI SC SD TN TX UT VA VT WA WI WV WY '),STATIC
Zips   STRING('99 35 71 85 90 80 60 20 19 32 30 96 50 83 60 46 66 40 70 10 20 39 48 55 38 59 27 58 68 30 70 87 88 10 43 73 97 15 00 28 29 57 37 75 84 20 50 98 53 24 82 '),STATIC

RandST SHORT 

!States STRING('AKALARAZCACOCTDCDEFLGAHIIAIDILINKSKYLAMAMDMEMIMNMOMSMTNCNDNENHNJNMNVNYOHOKORPARISCSDTNTXUTVAVTWAWIWVWYPR'),STATIC

  CODE
    RandST = RANDOM(0,SIZE(States)/3-1) * 3 + 1
    outState        = SUB(States,RandST,2) 
    IF ~OMITTED(outZip)
        outZip      = SUB(Zips  ,RandST,2) & FORMAT(RANDOM(001,999),@n03)
        IF ZipPlus4 THEN 
           outZip=CLIP(outZip) & FORMAT(RANDOM(1,9876),@n04)
        END
    END
    RETURN 

!    RandPos = RANDOM(1,SIZE(States)-1) ; IF ~BAND(RandPos,2) THEN RandPos -= 1. ; RETURN SUB(States,RandPos,2)
    
!!! <summary>
!!! Generated from procedure template - Source
!!! Return 1 latin word of 5 to 12 bytes
!!! </summary>
TestDataWord         PROCEDURE                             ! Declare Procedure
Latin STRING(',iaponicus,aduerbium,coniugatio,interiectio,nomades,tempore,temporum,temporis,tempori,vinorum,ducem,arcem' &|
     ',artem,ducum,marum,nexum,tantali,furem,furum,vicem,lucis,legum,iuris,furis,fonte,lucum,domum,rerum,murem,l' &|
     'ucem,nexui,flore,domui,catte,domos,annos,fonti,animalis,nexuum,rosaceus,vicum,flori,fumum,culum,iurium,dom' &|
     'uum,finem,iussu,fontem,dicti,fontis,publice,vicos,actui,floris,culos,cattum,florum,fumos,florem,animalium,' &|
     'filiam,fontium,assem,cattos,actuum,assis,finium,metri,domorum,filium,filias,assium,publicos,publicas,huius' &|
     ',ossis,cuius,aeram,apium,marem,ossium,filios,entis,quidem,pedem,dente,pedum,partem,pacis,canem,parti,corde' &|
     ',diabole,fumorum,nomini,entium,dotum,litem,vestri,dotis,mortis,ruris,solem,imbre,vestrum,donorum,dotem,par' &|
     'tis,parium,agnum,carmine,ursum,rurum,flumine,pacum,publicarum,morti,pedis,aeras,actorum,earum,atlantem,vic' &|
     'orum,culorum,ponte,agnos,denti,cordis,montem,buccam,ipsam,cordum,ursos,partium,pontem,cordi,imbrem,imbris,' &|
     'cattorum,dictorum,montis,ipsius,pontis,dracone,mortium,ponti,terram,taure,trabem,trabis,litium,carmini,lab' &|
     'em,terram,nominum,genuum,nominis,genui,dentis,nimbe,labis,dotium,flumini,eidem,morbe,dentem,dorade,pecinum' &|
     ',trabum,monti,carminum,verbi,lunas,fluminum,harunc,mulum,draconi,doradi,carminis,pontium,strige,actioni,te' &|
     'rras,aerem,nasum,ipsas,genubus,montium,doradum,cupri,filiarum,doradem,buccas,morbum,dentium,patre,panum,ni' &|
     'mbum,portas,pagum,zinci,cordium,ipsos,fluminis,imbrium,taurum,ararum,labium,dierum,panem,diabolum,porcum,d' &|
     'oradis,aereum,aerarum,morbos,actionum,strigis,eiusdem,eandem,strigum,metrorum,patrem,patris,filiorum,globe' &|
     ',orione,vestam,mense,patri,pagos,draconem,draconum,mulos,quarum,nasos,tauros,diabolos,origine,ursorum,sedi' &|
     's,nimbos,strigem,amice,leonem,draconis,patrum,mearum,actionis,leonis,eundem,saxorum,aereos,porcos,agnorum,' &|
     'actionem,rhene,leonum,strigi,sedum,iconum,munere,solius,helii,fluore,easdem,eosdem,plumbi,iconi,ipsarum,or' &|
     'ionis,aeream,sectore,atlantida,sedium,rheni,mensem,buccarum,mensi,origini,mensum,iconem,solam,amicum,digit' &|
     'os,globum,novam,graecum,terrarum,genuorum,orioni,iconis,tonsore,bromi,stanni,orionem,lunarum,mosellam,nost' &|
     'ram,fluorem,frictione,sectorum,verborum,taurorum,muneris,novos,novas,tonsori,sectori,solos,globos,tonsorum' &|
     ',sulfuris,pagorum,morborum,tonsoris,funere,muneri,originum,tonsorem,porcorum,amicos,aereas,originem,mensiu' &|
     'm,sectorem,sectoris,munerum,angele,nasorum,fluoris,urane,aereorum,nimborum,prime,originis,tamen,mulorum,so' &|
     'las,graecos,chlori,turcmenus,octobre,angelum,atlantidum,cobalti,nostros,atlantidos,lithii,atlantidis,earun' &|
     'dem,frictioni,funeris,primam,telluris,nostras,uranum,funerum,tellurem,telluri,atlantidem,funeri,tellurum,a' &|
     'micorum,dominam,novarum,octobri,primas,serpentem,serpenti,lunam,globorum,discit,octobrem,solarum,aerearum,' &|
     'angelos,graecorum,serpentis,frictionem,frictionum,primos,domine,consule,diabolorum,decembre,digitorum,mang' &|
     'ani,dominum,consulem,nostrarum,consulum,serpentium,consuli,astati,aeriam,consulis,dominas,dominos,angeloru' &|
     'm,septembrem,decembris,decembrem,primarum,solarium,novembris,septembris,facultate,solis,aerios,solem,novem' &|
     'bri,aerias,novembrem,decembri,septembri,facultati,dominarum,facultatis,quadrati,venere,facultatem,facultat' &|
     'um,argenti,niccoli,civitate,aeneos,veneris,venerem,sacaia,aeriarum,dominorum,veneri,americam,civitati,aene' &|
     'am,aeole,civitatem,civitatis,civitatum,civitatium,aeolum,quadratorum,adoni,iunone,adonin,aeoli,iunonem,iun' &|
     'oni,iovem,iovis,iunonis,petet,finnum,adonidem,aenean,iaponia,adonidis,raphaele,lunam,petes,amant,amanto,vo' &|
     'cer,vocet,coget,raphaelis,petis,vocat,novembre,raphaelem,petent,petat,raphaeli,vocor,coges,petas,vocas,cap' &|
     'it,capis,audiet,amantor,septembre,audit,cepit,aeneas,sitim,taxum,taxos,denique,cepisse,horte,vocant,capies' &|
     ',cogat,ametur,canta,amemur,vocent,ameris,ponis,ponor,petunt,iunxi,cunne,petant,audies,amemus,cogent,ametis' &|
     ',audiri,amamus,ponit,amatur,calle,coegi,audis,cogam,cogor,cogis,habes,cogit,generatione,cogas,coegit,capia' &|
     't,audient,amentur,cantat,albam,intror,amatote,habeam,cantet,generationi,habent,petetis,audiat,casum,petemu' &|
     's,canter,capior,lucri,iunxit,iungis,intrer,habeat,capient,altam,avorum,petunto,iungit,iungent,cantem,cunas' &|
     ',cantes,habeas,magne,oremur,altos,caperem,oretur,generationum,caperet,cantas,generationis,albas,generation' &|
     'em,oratur,audite,albos,malas,cogunt,febrim,altas,cunnum,aristotele,ponunt,casui,cantari,petitis,uvarum,ama' &|
     'ntur,oraris,cogant,oreris,canos,callem,hortum,habete,capias,bella,turrim,petimus,audias,cogite,caperer,pom' &|
     'os,oramur,petitote,caperis,audiant,ceperam,vocamus,caperes,cantant,habeant,cepero,veram,aristotelis,aristo' &|
     'teli,iungunt,vocemus,orantur,lenium,voceris,piarum,ceperat,capitur,navium,capiunt,cogeret,cogemus,petatis,' &|
     'aristotelem,cogunto,cunnos,vocemur,caram,vocamur,cogetis,audiunt,casuum,cepimus,capimur,capimus,intrabo,ca' &|
     'piant,numere,cantabo,vocetur,cantent,vocaris,informatione,sanam,ovorum,petamus,hortos,vocetis,amemini,sens' &|
     'u,vocatur,iungant,ceperim,audivit,rubram,cantanto,lentam,quercu,rubras,caros,rubros,cogebat,sensum,intrant' &|
     'o,auditis,capieris,informationi,cogitis,cantabis,cogebam,capiemus,capietur,intrabit,turrium,audiunto,angli' &|
     'am,magnam,cogimur,vinis,cogeres,castri,ponimus,cogimus,audiemus,vocantur,intrabis,vocentur,cogentur,poniti' &|
     's,ceperas,fortium,veras,phosphore,audimus,cogitur,cantabit,habetis,taxorum,audietis,suffici,habemus,cogunt' &|
     'or,cepisti,callium,capietis,caras,capiemur,intrabor,multam,febrium,caperent,sanos,capiunto,capitote,phosph' &|
     'ori,cogatis,cogamur,cepissem,phosphori,cantarem,cogerent,cepistis,capiebar,magnas,cogatur,iungimus,intrare' &|
     'r,longos,intrabat,cantabat,sensui,cepisset,medice,cogamus,audiuntor,intrarem,salutis,capiebat,cantabam,mul' &|
     'tas,salutum,cantaret,multos,intrabar,cantantor,ceperant,intrantor,lentos,cogebas,iunximus,iungitis,salutem' &|
     ',coegimus,longas,cogaris,capientur,oremini,capiuntor,capiebam,quercum,magnos,numerum,intraret,lentas,audit' &|
     'ote,altarum,intremur,capiatis,intramur,canarum,coguntur,cogebant,cantemur,capiaris,audiatis,intreris,canta' &|
     'res,cantaris,cantatis,audiamus,sermoni,vocemini,phosphorum,capiamus,cantatur,cantabunt,intratur,cantetur,s' &|
     'peciem,ceperunt,virtute,cantamur,cepisses,cantavisse,capiamur,habeamus,cantabas,cantemus,habeatis,malarum,' &|
     'capiebas,cogantur,cantetis,sensuum,coegisti,albarum,numeros,capiatur,intretur,intrares,cantamus,intrabas,p' &|
     'hosphorum,cunarum,suffice,maris,quercui,intrabunt,iunxisti,intraris,rebus,quercuum,capereris,cantarent,can' &|
     'tabant,capiantur,hortorum,cantantur,nivis,lucrorum,capiemini,speculi,audiveram,coegistis,sermonem,vocum,vi' &|
     'rtuti,arcis,intratote,audivimus,intrabant,caperetis,intrarent,cibos,exequia,sermonis,audiverat,capiebant,a' &|
     'ctione,audiverim,nivium,intrentur,caperemur,cantentur,sermonum,cunnorum,intrantur,cepissent,cantatote,capi' &|
     'untur,sufficiet,virtutis,dicer,medicas,cogeretis,sufficit,virtutem,virtutum,athenas,ceperatis,foris,sanaru' &|
     'm,rubrarum,intrabitis,ceperamus,cantabimus,ducibus,medicos,sufficis,audiveras,dicem,viros,verarum,cogamini' &|
     ',caperentur,cararum,intrabitur,audivisti,cogeremus,iunxerunt,cantabitis,coegerunt,intrabimus,arcui,intrabi' &|
     'mur,intraberis,vocis,cogebamus,cylindre,intremini,audiverant,sufficies,longarum,dicari,multarum,existo,lat' &|
     'inam,magnarum,intraveram,nivem,intraverat,cogebatis,audivistis,virium,suffecisse,auras,capiamini,cantemini' &|
     ',marium,arcuum,lentarum,caperemini,latinos,virorum,cantabatis,castrorum,intrabatur,intraretis,cepissemus,c' &|
     'apiebaris,intrabatis,intraretur,capiebatis,intraremur,capiebamus,temporibus,intrabaris,capiebatur,intrabam' &|
     'us,intrabamur,sufficiat,audiverunt,intrabuntur,catto,cantaretis,capiebamur,cepissetis,intraveras,cantaremu' &|
     's,sufficite,intraremus,matri,cantabamus,intrareris,numerorum,latinas,vulgi,intrarentur,matre,opibus,cylind' &|
     'rum,assibus,ciborum,specierum,intrabantur,aurim,matrum,capiebantur,intraverant,civilium,sufficias,intrabim' &|
     'ini,medicarum,actis,legibus,sufficiunt,vicibus,cylindros,nexibus,genialium,iuribus,sufficiant,dicantor,dic' &|
     'ite,lucibus,domibus,sufficitis,donis,muros,dicunt,audiveratis,audiveramus,athenarum,sufficimus,adpello,fum' &|
     'is,furibus,culis,celerium,sufficiemus,eorum,acrium,intrabamini,ossibus,quibus,apibus,speculorum,murum,aeru' &|
     'm,sufficiunto,numerabis,sufficietis,sufficitote,intraremini,ipsis,matris,frictionis,cattis,dictis,capiebam' &|
     'ini,intraveratis,latinarum,dicimus,acuum,dicitis,murorum,dicitur,vulgum,martis,intraveramus,genere,filio,d' &|
     'icimur,dicuntor,sufficiuntor,metro,litis,paribus,ursis,fontibus,isdem,saxis,horum,entibus,agnis,plure,sulp' &|
     'huri,imbri,terrae,sufficiamus,matrem,acere,sufficiatis,ipsae,pontum,finibus,minore,martem,euros,sulphurum,' &|
     'actibus,sulphuris,capacitati,cylindrorum,atlanti,dicuntur,pendete,capacitatum,genibus,lunis,pacibus,partib' &|
     'us,porco,solibus,appelle,litibus,horunc,ruribus,aereo,mortibus,minori,pluris,nimbo,capacitatis,eurum,terri' &|
     's,tauro,facti,morbo,canibus,dotibus,capacitatem,buccis,cupro,iisdem,portis,veribus,pedibus,diebus,floribus' &|
     ',verbo,metris,annum,eisdem,annorum,minoris,remos,optimam,minorum,tellure,eurorum,lupos,animali,felem,locos' &|
     ',plurium,multe,optimus,dentibus,nimbis,iidem,eaedem,trabibus,filiabus,' ) , STATIC ! Length = 8972
WordRet     STRING(64),AUTO 
MaxRandom   LONG
RandPos     LONG
Comma1      LONG
Comma2      LONG

  CODE
    MaxRandom = SIZE(Latin) - 31
    RandPos=RANDOM(1,MaxRandom)

    Comma1=INSTRING(',', Latin[RandPos : RandPos + 20],1) + RandPos - 1
    IF ~Comma1 THEN RETURN 'WordFail1'.

    WordRet=LEFT(Latin[Comma1+1 : Comma1 + 20])
    Comma2=INSTRING(',', WordRet,1) 
    IF Comma2 THEN WordRet=SUB(WordRet,1,Comma2-1).
    WordRet[1] = UPPER(WordRet[1])
    RETURN CLIP(WordRet) 

!!! <summary>
!!! Generated from procedure template - Source
!!! Format Error() functions for message or (1) for log
!!! </summary>
Err4Msg              PROCEDURE  (Byte FmtType)             ! Declare Procedure

  CODE
    CASE FmtType
    OF 1            !the 1 line format for use by logging
        RETURN  ERRORCODE()&' '&CLIP(ERROR()) & |     ! {148}
            CHOOSE(~FILEERRORCODE(),'',' [Driver ' & CLIP(FILEERRORCODE())&' '&CLIP(FILEERROR()) &']' ) & |  !driver error in []   !8/30 Carl was CHOOSE(ERRORCODE()<>90 but err 47 too, assume blank
            CHOOSE(~ERRORFILE(),'',' {{' & CLIP(ERRORFILE()) & '}' )   !Just throw a line break so the file is below

    END
    RETURN  '<13,10><13,10>Error<160>Code:<160>' & ERRORCODE()&'<160>'&CLIP(ERROR()) & |     ! {148}
            CHOOSE(~FILEERRORCODE(),'','<13,10>Driver<160>Error:<160>' & CLIP(FILEERRORCODE())&'<160>'&CLIP(FILEERROR()) ) & | !8/30 Carl was CHOOSE(ERRORCODE()<>90 but err 47 too, assume blank
            CHOOSE(~ERRORFILE(),'','<13,10>File<160>Name:<160>' & CLIP(ERRORFILE()) )
            !<160> should be hard space in most fonts       
