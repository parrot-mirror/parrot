# $Id$

use strict;
use lib '../../lib';

use Parrot::Test tests => 6;

sub test {
    language_output_is('python', $_[0], '', $_[1]);
}

test(<<'CODE', 'pi() func');
def pi():
    k, a, b, a1, b1 = 2, 4, 1, 12, 4
    n = 0
    while 1:
        p, q, k = k*k, 2*k+1, k+1
        a, b, a1, b1 = a1, b1, p*a+q*a1, p*b+q*b1
        d, d1 = a//b, a1//b1
        while d == d1:
            n += 1
            if n > 20:
                print
                return
            print d,
            a, a1 = 10*(a%b), 10*(a1%b1)
            d, d1 = a//b, a1//b1

def main():
    pi()

if __name__ == '__main__':
    main()
CODE

test(<<'CODE', 'pi() func 1000 digits');
def pi():
    k, a, b, a1, b1 = 2, 4, 1, 12, 4
    n = 0
    while 1:
        p, q, k = k*k, 2*k+1, k+1
        a, b, a1, b1 = a1, b1, p*a+q*a1, p*b+q*b1
        d, d1 = a//b, a1//b1
        while d == d1:
            n += 1
            if n > 1000:
                print
                return
            print d,
            a, a1 = 10*(a%b), 10*(a1%b1)
            d, d1 = a//b, a1//b1

def main():
    pi()

if __name__ == '__main__':
    main()
CODE

test(<<'CODE', 'pi() generator');
def pi():
    k, a, b, a1, b1 = 2, 4, 1, 12, 4
    n = 0
    while 1:
        p, q, k = k*k, 2*k+1, k+1
        a, b, a1, b1 = a1, b1, p*a+q*a1, p*b+q*b1
        d, d1 = a//b, a1//b1
        while d == d1:
            n += 1
            if n > 20:
                return        #raise StopIteration
            yield d
            a, a1 = 10*(a%b), 10*(a1%b1)
            d, d1 = a//b, a1//b1

def main():
    i = pi()
    for y in i:
        print y,
    print

if __name__ == '__main__':
    main()
CODE

test(<<'CODE', 'izip() generator');
def izip(*args):
    # (xrange, iterable) =>
    args = map(iter, args)
    # [range_iter, iter]
    while 1:
        yield tuple([x.next() for x in args])

def main():
    for x, y in izip(xrange(10), "abcdefghijklmnop"):
        print y,
    print

if __name__ == '__main__':
    main()
CODE

test(<<'CODE', 'izip() generator with pi() object');
def izip(*args):
    args = map(iter, args)
    while 1:
        yield tuple([x.next() for x in args])

class PI(object):
    def __iter__(self):
        i = 0
        while 1:
            yield "314159265"[i]
            i = i + 1

def main():
    pi = PI()
    for x, y in izip(xrange(6), pi):
        print y,
    print "ok"

if __name__ == '__main__':
    main()
CODE

test(<<'CODE', 'b2.py');
def izip(*args):
    # (xrange, pi) =>
    args = map(iter, args)
    # [range_iter, generator_iter]
    while 1:
        yield tuple([x.next() for x in args])

class PI(object):
    def __iter__(self):
        k, a, b, a1, b1 = 2, 4, 1, 12, 4
        while 1:
            p, q, k = k*k, 2*k+1, k+1
            a, b, a1, b1 = a1, b1, p*a+q*a1, p*b+q*b1
            d, d1 = a//b, a1//b1
            while d == d1:
                yield d
                a, a1 = 10*(a%b), 10*(a1%b1)
                d, d1 = a//b, a1//b1
                self.a1 = a1

tests = {
 99: 44251238236192885942548145627920559612834490019477028496725657079267312460031559302172150714110203307954379217477379106929168768496503354540899921113305213841256909892518928098307564463751633347248940009920269109969147590732355948788056064000000000000000000000000000000000,
 199: 1000596230862142822590229503409372398669386421051058756167623955196210292140473223995201364067656314884093070923379776058593112593572415388874119773448702613069929696236969954099574382312021625484547051647005317079077091903572365445691946982207111619679684359784089545801152269560862321544414943514190096631259179363627029133476495865659666812167626608236901769581685802712761140555948794720353924341042650072696819415055421183957924869318180281662429407332762869255321912813711898750492786968744984544308467386273640507277517829133760299081875243110913120665600000000000000000000000000000000000000000000000000000000000000000,
 299: 21435887192948215614003242240833359745116667655295850182859413191163731683078952650094326080502769326477126925083216343548170734614172935170340269921309820711302999200539819947867212813551107194027554006207604344128185286047718105667902068109038526051946371288160859880626765253522805513232333491975220030085760604224065673379016506268781757490866758397031010384977255107445504115787686395015630645137203786798858795200871880590717053675063928230569710372699708910775901232998621866511805494494875255496291270721486641615650345940568291905806263698337995119757061129615716444504290546816572960918445558805410505143000167480199333531897643812998836381668261331434305825321676717544726859895857274900170645624087291170408290210800888136650695682668742663263729788760787553650802761860581841523193434651375248115751262481847514479478467508156570863734207165375573520453327647345580868727572348946580766720000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
 399: 8561869806834798989612544773400323313179941907807794568262440743112858898989689026704576126118595731944427372856665962019724479801384062969795859298394962551328689077803363555807984316902252940902014889926277022833163566635584197843427728248130112186455323888931447608868707068434776186855353396855833436850229162071581300162579548898284489248532968742303181986647234058212952485789589428331561779973912890270787218670895308761530690791268509970600822462460658693835169935042766248145148420454545182598329186640466821688459819069501551463819641554408111110110151692239551586768176506251155525099233988638762885805917822379263713549352362861698409524070686169569736102177070749091831233867352657647277185192372387156966362270318951122024815096048593017226290871189781143762422618457018186519922454408157004798904710507709224018924427721086955924703838793251170380074666507887931281809304737450536142489860864008197549841329444837980614206463968734383477281485253049376604442937718053220015067951581390345559841730246517326234188422995410478560583662283465682728995404843025593838691776410644612449087517702830166590175727603809091974002341560317871295071902646575676785149353532452189474547463794343581915053692213809212940949327454179290314595392041251528682462248960000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
 499: 76766108631940210937325132198465864457610296920889901883030849944249491732767613231460026747961565950406551576277982908797232709115573397680840144587889878137072051513231549168224623486940739011824470282874235014299280185292476357855772342908560617765615433859648152443400651562464645577267133565969609608350684571285655853054712724572601634219899681603288076555568556603519768176952205317390973803424356164269999588467102540378584128532600037700811666341008358928602746642205050531572408717173194538376392544677893444983399212894400285344939556094505296780409965886324800278706769664438849417755796690865276144102933659458633433715362955199895852120250371111523601408509601075849463319256275384860431711268141908667883149791804139967338545358206127158990156425480764804297397170597657279674744907448120365194723760375846968550637839625396799787981542068069955660525855300927415620426941417314885401820985001913260101401230309399239801959598342546866307638278153091955749126275448041244876145703346573865766318100310570772620069178810413227974410262538853025115028173981758758325369986648321051017250246765567173447382346682177940131720445933725662183060319023268847648849199144024316405375647697684691770109145226746285626861260128121857903981514928439560981950894568063766637808949718925624322085933716705575498276564370619232206346293654148202964613950060056885972213718288213503135634713342418000998239413319648014225323725957085146390629354204147053598603318165064363587092287902579232811848133423379877761425679796787506376625832936596918827500201870173625427859893528696839243761272981017048564872611531028386533983068887010900245332623360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
 599: 2120272365916624093549573503339645760249925590629691905298380620826238336680485250775748238851715242513568106491781607325637843266230182543159994052803483210198817868787245904539293723939615230218367927170630181008508608682473786334989642773309671087946382125393064054429291378005365307369932354974406782493586482693959468507929142578311374952191246685196652549840632791830721769718961140786765636611636126263231624375986806336404014991356931344468888703169171934706250411475009307785661110741777527324954571089817794240318090318731138065871311050896639596947512824176632981670282022349794742982306588866780679141100000979482012703431996529614153969006965379857532250140411692707925832547131496348527554204126276904033851312192294719407040113066259294928824359144110570802157647067643172691886034509485269315724734491380423529629749223874238867299576969461404272650055836211201773406419214625694511195241201118512536217548368603119794507877569790693417734860149658615068452866115479874379764219274786787905887717695084355702688921163181942859261931462396527992761425892799259213253073620895655262890187342553757398412577032172382168869416402722279336223791913538036339921582169629706204936615017408331600286347593291767969984872197163003714688529499720018226023559039421196525971154371211007274491079331581462202803270308044945895467086216358487714539723075423709132632711104176237158591348264918119231549610638101215271635751068862184966089290055162842592702917037089658541420657556777630476720227083286444062812384078931053717097690428021828828314330897267550018034334466896893522629282170940447351039396227633740743904716345874216287187030893375694818646093977919289909500326805873535353890952168548557367192114315242338374030375201461534835392764765715654233759268109399742689152068054720118040413609079726305828412608467329058007828176699982184798481881032984952414016677410029974950886156526807807461864142760141455419659333722571838033134676308170730229830331659493070917764742995587861083129433623003009634591950055674021412864000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
 699: 54571787430958399400005671895793395810514965360222657069233155257869831245514703898329984842599345345797192550495348877752750716462799995262238897879189712362792599540276947290240369738995122870036473426596166137781512133732841079442335809215673962548136751501962395101508082458022910749004870763777751025686143054266560789699467897488208314352497922931109255090615845989365253963697070552088326927571730238674587343725408556548847027815257453311184273200959063948470485405418687785822617652671609706936044865165112267634536255942342137737568633616435112070199187087675353099732490445262584463118808715533880843287282323502172455874549895164201021082781039664171931972950867328706112021059604060340338606871763348783573247509755207096610318069014034226371127241365822041636184401808035853347524245498756203483212762819194058857286022123510755206330238728338540936417830717262921800876426685863489447721974523840880601732138137563579815785444094205972614263669956513740906383728059662729451143837852557411654864608820606495589950458165214874335528071914274226508583618548221498046257433189345079263951024381261213067438755400772554918420156611989161275819373340626340095277962552853128100524758416265525218190626769969209796740560920753972479878773975562043659464796071536492340776053077906431346958246988865607675041671683462291933241209943247185229400300531069434821908210393754215270727867860747889887039965048681895147820192799637449521165944356200714071125353390157596677223069290303004608406259263260481747075716421783084148765931010321931117509077808771925529544210503591442107960112359151446110353540208471607107935843590192610650273333834161753099980189676608843057569018657095864002224328579690446259626925339472680838762568611923981193711770106009098171810029820020455115170724929203588390317815053369572788421300357832205199443876759544538582639402241883694827090801385537555747373037489025563879252287165075989079784157761408131323383708336366882662138204724992104184118234360573248835518448645547172342375665655653335218281979099552819760633230580536381778069677840715358530867566196795457417775340310424672192141977398974880862555283206621628790868960591215870136675469162920111812154003932444777532696287441691534774646863311895804406055064912499462089287403059782748799895590902455779428144219297715674077436643273687702239680646741926247202392605642085420467071089682849156330161168666278561180452156752478501391564800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
 799: 1165019969951028145448474870606694745628445847100063691175045426809524271280385211025149309439736889668431363205043295468478227885516089826430304252028412665878074268391689531376676369814346541259212014204219732753532556283167763492813491981617042686520428375483043823229347180225027527767892288494222400268347648277077085092324780438909293027666621101974271603717458184633691745699246613625445708958093814173789616468299755424767037016330877693069425266688538600904598289113523091543776886739998104937757229618512461155015780709364046160704463608630709906484636013448672656426886594747044346764985843639265457373603772739772415706169602575546300922342271055004256781082363315561913547648640954959000371679492600850323235849380042831378495135583566599574416729516620087245906062795758387578224336805373895492794645806096068657974185136831114580747646909717985162654700150389838526549868770885629372149350446773860669388038471776557526515910033467628431871878316408982723876203877207112913665539371348724351835198296871265983857890498623536324848877236019869092878781427110113542625110041789002286754615039920319343770043455657828924442170211652589212117516714709894518726603532996156030790024814913146519305169722564850597797774298352669973544466122022123500758687471133096300448171087716127901248915474363042779227724255413335477296839171260050411230913787907606725169016351209025747882086625397286625248376528998919634710302520393941530723973487259019187136668425367426482695231240294671376146585312211926447150542843171266291876037378067256463777431998792250381914496818845072319002851834894280540179694233589184751221721345515353061996569633890293841751623667699605067183984407638732497881628999347219982736106675680165842644133894916782230987223224828685930858657631697327168501437432678530579280064943872275218623486567776580213001821563007802859121520206862366831214550454660201924592069971928484116327345227633650931220240412989380696156101840018564700065411677388328804161110162279193672651278988425644004188569635636717470803677943610275223854671409519817008772946235477341217799495629951132446716193818794636841421507151304976152511616538200203214016457449981017869162192339882870379247422061597402496664647115346984746108902369843975335083490551753570803795438395111351577474760022446140821780548147639308232794984562286077490121188360571079033300272391145791202144846667875284539709679647945779713567130240017333648976286204155043105228295725874012316502327195124092416348347162737242449541649547547864777887315161229040122603297586496999009079092644539172087825680666618082263897443172558909377634579572489890372823889386192559147381373832288039653312458442917119615324859008094386594830981911977813106096806546361863080294950465184145762955879704231094550954751577536624215411479046060449038350499002129406780206980907086223769600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
 899: 1961047400783793689152743738482061418112144594775859100963826903299941791245038595034363753615746408049289952725779309407444199325053710536522401903643581802543713504158806047235695705896380364921365885372696677158825553172792575130365677811577035805389273355225725863414284665498055318575649394451227797767110728923709058788425788790167032831982217805891947591307310391793051324726126078967699521915868839204118521519682024094610098117626863292184721906092521438801341497303557767071828077146885364536554032450624100316867547877010778603956083487035270791818649067384276377414249363983383717773036457804718062695046059095787213719308297709919175747285036636352990899483938970896812239613605956608649083554411609657838220544027128950682327843798882711829991989817881303883990647876969994768271897974773455464646523348820392471256024577102382204328939384060235197563409904986708133897802121211859685551906620747824874847127776411443039694389051592145124635490844378130255642752765693890407120283111284316765000645749180288822505352501861257195960128525960418404774436619529817773459198268065709767064598308082608109337158602927125644880036055446842995394476366770872364117175239884406760485305848864493739499504392963295387516098554438251252486287315978444632100288391159069513665622892184147377430660017269064216314044538754986908504965776567592061950572488346266774840439392992871099154439658791611017807192708601473794082677034875991711712839230126426791071352984543648012937947037753575375040046764495862676093683555226439651695465214815214564045671683209573744703248122302073524235222782011551736047484049940566608761314884952385623657426286984431299387264223494331247251695035920997630045288051985796581735253031855095734994702323372767680434320372371358208514386161807824094211406017077057681618563506824462507672499213262962050653636150604636813302357401076353456780306366770399402263353459513732101609057936629596760862766436204974584026785745826067150601651416509653311312257323521470962454567693169469818165574943846754385013710385609445073226065759614555740278029180864101039640157003847772681461933766608520730602890319871123179941870008811420475967031993019721292183133758093949406939652398599519672662411049142220315039805474111098855767170048770783560759174013367296946638271656238787420981851702619053744806332012493178141602213898668388712998512756036771357385206948329239298807516694953814693720048229647293048056331265195037121054022115441868442670280473506498551412297880384312473713380564764159899942048060356745863908010902230964075673990385182437331505988923117412916700150241837983775128046411352228138119876809545584444570443347872856695813698044037133648970190072128464354669077148179236958137004869599834164764747494805309536229934978506910688264436888356383974787838537387187841566823557909442831563769727985839249267304457033791105118767948473474042809317178565809335268316324420040570235176099114072999727457879465811886218940986224633055296998229833996940360896329868864364653862830780554332074293100857235815847819975826812991652016737242925678140172314816371649578265526072666356756752517107018796020915298198762366163369556351250086487862926783601433251979292229580324497550784524234395521051827588464289592550437275513651200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
 999: 51421204237426754719741262879558095745353570680465295990005607280393992759309313043417054432903002299144227267946681775379682646481441184984878051192262603785286501319910886769028368118572705415132969475266997058807303812945930068988142620857043364738252015410062109557537048105374131205551289070131067641702104206291269602159585410011716588325959509072295414578340882094129449369050539722183971427768493446582776526148926808216744196972229231300146452844798957170562743924910341252019551586744505512178746646209409281714276837540692337365091849265903691838950705920069247812720998641002393637705464518833183499641523989489319666798606026274099063316447636791376824977802426300098229217109293397613448627314578264206176863819689114000733923661247770659874248361262500335796860850821012664671771458632988533081782215409765802283312397639531087374886914931818336434018365581917786263986184421404682182700668580256406614910005588986105283922797115795753457032007852784163484117726758402807095937775274740959221797164713537199602017041055883470864790221601914448307560964005337053911966953966628791679568034533608103498461484413180826592737887173295962464948084846329227317763485710127958570474521805846289864427724437000806760496738191498562549124089519328261857651962598014067174275024135581089311586662613800674556590447284302589227994020980213920576606410812288774224985213146245744417408945081781113854100049114396677026962371599785096891808223814416164195820685147641538762223075545475947323585115274444998974587593729824337921226549035616388426184445157848256274480718496342976431693624096685162227580762036981450014151173230060384257039659147964264276717849828738171682245892581306830589179887337090011464839646134568754370139845055418256890860940757057604372114023858733686778293659768364688584313980891657494820666567128494973417651689810011217228920255038016092697827501659126864128552793815957798765294279442644144781212010235659076921083028766195306983520086051010702064687047067852692614939864275238659313772070485512507854113183292498557795177864634776519676116960767383666934404120846954899842398644565635321658409635828642860494805612307530127024621301271374503453503593598678825472356837105710187840164939100381680149781533530971702548427150353351891790289793371198307811983920633373141553344786366833632629827394060040022660478432725820719166178073536817127815814516804684768909331366393380845665808090480804683597798069345611863676423593435458367296114919445047864192204991424873907600867560652360433332333460605503950202643081773051851931329700798978585023149558510051756813823934151345468518744914658396602698567997395883907886162856223081161171378840724659535879555133476804981500946142310178618715717330537589699297655080875880600325195469690780842623951417080052370551017667164713224427292680078173002890766115232008277162207593058978389851005689429106305813929315214127108126116277803514751388254341941007906487414087391653272683247248144900228323654135725469516828248483753155121402474188091072172874050555155865413230544137360090574915682856355897339880759959552597891337880610141176123727002295219377091215365686168970240859719317085650982416219558886127398895904298964883158265272486775477666044730446436805318892171895199489563024683292416174451463979862792856107202456073408125335089494339729358670332578718476101211422277469149701783270075855888742583964446418851379385457754248170422546014640203546645610651326807707725840711263654208439193695249007802516372736393165515067274768773964565908592407847748333876331474804846330009526035593873778287836699826905094860721603742076784651700242126831347444508393439010605679605183038164877451729777036414156800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
}

def main():
    pi = PI()
    checks = {}
    for x, y in izip(xrange(1000), pi):
        print y,
        if x in tests:
            checks[x] = pi.a1
    if tests != checks:
        raise RuntimeError

if __name__ == '__main__':
    main()
CODE
