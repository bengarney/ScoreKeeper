package
{
    import loom.Application;

    import loom2d.events.Event;
    import loom2d.text.TextField;
    import loom2d.text.BitmapFont;
    import cocos2d.LoomKeyboardType;

    import feathers.system.DeviceCapabilities;
    import feathers.events.FeathersEventType;
    import feathers.controls.PanelScreen;
    import feathers.controls.TextInput;
    import feathers.controls.Button;
    import feathers.controls.Label;

    import feathers.layout.VerticalLayout;
    import feathers.layout.MultiColumnGridLayout;
    import feathers.layout.MultiColumnGridLayoutData;
    import feathers.layout.AnchorLayout;
    import feathers.layout.AnchorLayoutData;
    import feathers.themes.MetalWorksMobileTheme;
    import feathers.controls.ScreenNavigator;
    import feathers.controls.ScreenNavigatorItem;
    import feathers.motion.transitions.ScreenSlidingStackTransitionManager;

    public class ScoreKeeper extends Application
    {
        public var theme:MetalWorksMobileTheme;
        public static var navigator:ScreenNavigator;
        public static var loginMessage:String = "";
        private var _transitionManager:ScreenSlidingStackTransitionManager;

        override public function run():void
        {
            DeviceCapabilities.screenPixelWidth = stage.nativeStageWidth;
            DeviceCapabilities.screenPixelHeight = stage.nativeStageHeight;
            DeviceCapabilities.dpi = DeviceCapabilities.screenPixelWidth / 2; // Assume a 2" wide screen.

            // Register fonts.
            TextField.registerBitmapFont(BitmapFont.load("assets/arialComplete.fnt"), "SourceSansPro");
            TextField.registerBitmapFont(BitmapFont.load("assets/arialComplete.fnt"), "SourceSansProSemibold");

            //create the theme. this class will automatically pass skins to any
            //Feathers component that is added to the stage. components do not
            //have default skins, so you must always use a theme or skin the
            //components manually. you should always create a theme immediately
            //when your app starts up to ensure that all components are
            //properly skinned.
            //see http://wiki.starling-framework.org/feathers/themes
            theme = new MetalWorksMobileTheme();

            // Initialize the ScreenNavigator...
            navigator = new ScreenNavigator();
            navigator.addScreen("score", new ScreenNavigatorItem(ScoreScreen, { complete: "login" }));
            stage.addChild(navigator);

            // Start us on the score screen.
            navigator.showScreen("score");

            // Schmexy Transitions
            _transitionManager = new ScreenSlidingStackTransitionManager(navigator);
            _transitionManager.duration = 0.4;

            stage.reportFps = true;
        }
    }

    public class ScoreScreen extends PanelScreen
    {
        public static const SHOW_SETTINGS:String = "showSettings";

        public function ScoreScreen()
        {
            addEventListener(FeathersEventType.INITIALIZE, initializeHandler);
        }

        public var scoreColumnCount:int = 4;
        public var scoreBoxes = new Vector.<TextInput>;
        public var totalLabels = new Vector.<Label>;
        public var rankLabels = new Vector.<Label>;
        public var rowCount:int = 1;

        protected function initializeHandler(event:Event):void
        {
            const mcgLayout = new MultiColumnGridLayout();
            mcgLayout.columnCount = 5;
            mcgLayout.columnGap = 8 * dpiScale;
            mcgLayout.rowGap = 8 * dpiScale;
            layout = mcgLayout;

            // Do the header row.
            addHeaderRow();
            addTotalRow();

            for(var i=0; i<10; i++)
                addRowOfScores();


            headerProperties["title"] = "Score";
        }

        public function addHeaderRow()
        {
            var roundLabel = new Label();
            roundLabel.text = " ";
            roundLabel.layoutData = new MultiColumnGridLayoutData();
            addChild(roundLabel);

            var player1Label = new Label();
            player1Label.text = "K";
            player1Label.layoutData = new MultiColumnGridLayoutData();
            addChild(player1Label);

            var player2Label = new Label();
            player2Label.text = "B";
            player2Label.layoutData = new MultiColumnGridLayoutData();
            addChild(player2Label);

            var player3Label = new Label();
            player3Label.text = "J";
            player3Label.layoutData = new MultiColumnGridLayoutData();
            addChild(player3Label);

            var player4Label = new Label();
            player4Label.text = "J2";
            player4Label.layoutData = new MultiColumnGridLayoutData();
            addChild(player4Label);
        }

        public function addRowOfScores()
        {
            var startIndex = numChildren - 2*(1 + scoreColumnCount);

            // Add a row of inputs.
            var row1Label = new Label();
            row1Label.text = rowCount.toString();
            rowCount++;
            row1Label.layoutData = new MultiColumnGridLayoutData();
            addChildAt(row1Label, startIndex);

            for(var i=0; i<scoreColumnCount; i++)
            {
                var scoreBox = new TextInput();
                scoreBox.maxChars = 3;
                scoreBox.prompt = "?";
                scoreBox.keyboardType = LoomKeyboardType.NumberPad;
                scoreBox.layoutData = new MultiColumnGridLayoutData();
                scoreBox.addEventListener("change", onScoreChange);
                addChildAt(scoreBox, startIndex+i+1);

                scoreBoxes.push(scoreBox);
            }
        }

        public function addTotalRow()
        {
            var totalLabel = new Label();
            totalLabel.text = "Total";
            totalLabel.layoutData = new MultiColumnGridLayoutData();
            addChild(totalLabel);

            totalLabels.length = 0;
            for(var i=0; i<scoreColumnCount; i++)
            {
                var scoreLabel = new Label();
                scoreLabel.layoutData = new MultiColumnGridLayoutData();
                scoreLabel.text = "?";
                addChild(scoreLabel);

                totalLabels.push(scoreLabel);
            }

            var rankCaption = new Label();
            rankCaption.text = "Rank";
            rankCaption.layoutData = new MultiColumnGridLayoutData();
            addChild(rankCaption);

            rankLabels.length = 0;
            for(i=0; i<scoreColumnCount; i++)
            {
                var rankLabel = new Label();
                rankLabel.layoutData = new MultiColumnGridLayoutData();
                rankLabel.text = "?";
                addChild(rankLabel);

                rankLabels.push(rankLabel);
            }

        }

        protected function onScoreChange(e:Event):void
        {
            // Recalculate the totals.
            updateTotals();
        }

        protected function updateTotals():void
        {
            var totals = new Vector.<int>;
            totals.length = scoreColumnCount;
            for(var i=0; i<scoreColumnCount; i++)
                totals[i] = 0;

            for(var row=1; row<rowCount; row++)
            {
                for(var col=0; col<scoreColumnCount; col++)
                {
                    var idx = (row-1) * scoreColumnCount + col;
                    var box = scoreBoxes[idx];

                    var boxScore = Number.fromString(box.text);
                    if(boxScore == boxScore && boxScore != null)
                        totals[col] += boxScore;
                }
            }

            // Update the total row.
            for(i=0; i<scoreColumnCount; i++)
            {
                if(totals[i])
                    totalLabels[i].text = totals[i].toString();
                else
                    totalLabels[i].text = "?";
            }

            // Update the rank row.
            var sortedTotals = totals.filter(function(v:int):Boolean { return true; });
            sortedTotals.sort(Vector.NUMERIC|Vector.DESCENDING);
            var ranks:Vector.<int> = totals.map(function(v:int):int
            {
                return sortedTotals.indexOf(v) + 1;
            });

            for(i=0; i<scoreColumnCount; i++)
            {
                if(ranks[i])
                    rankLabels[i].text = ranks[i].toString();
                else
                    rankLabels[i].text = "?";
            }

        }

        private function onBackButton():void
        {
            dispatchEventWith(Event.COMPLETE);
        }
    } 
}