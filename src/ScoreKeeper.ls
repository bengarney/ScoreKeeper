package
{
    import loom.Application;

    import loom2d.Loom2D;
    import loom2d.events.Event;
    import loom2d.text.TextField;
    import loom2d.text.BitmapFont;
    import loom.platform.LoomKeyboardType;

    import loom.graphics.Graphics;

    import feathers.system.DeviceCapabilities;
    import feathers.events.FeathersEventType;
    import feathers.controls.PanelScreen;
    import feathers.controls.TextInput;
    import feathers.controls.Button;
    import feathers.core.FeathersControl;
    import feathers.controls.Label;
    import feathers.controls.Panel;
    import feathers.controls.ScrollContainer;
    import feathers.controls.Scroller;
    import feathers.display.TiledImage;

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
        public static var theme:MetalWorksMobileTheme;
        public static var navigator:ScreenNavigator;
        public static var loginMessage:String = "";
        private var _transitionManager:ScreenSlidingStackTransitionManager;

        override public function run():void
        {
            DeviceCapabilities.screenPixelWidth = stage.nativeStageWidth;
            DeviceCapabilities.screenPixelHeight = stage.nativeStageHeight;
            DeviceCapabilities.dpi = Platform.getDPI();

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

        protected function headerFactoryImpl():FeathersControl
        {
            return new FeathersControl();
        }


        public var scoreColumnCount:int = 4;
        public var scoreBoxes = new Vector.<TextInput>;
        public var totalLabels = new Vector.<Label>;
        public var rankLabels = new Vector.<Label>;
        public var rowCount:int = 1;
        public var scoreCanvasContainer:ScrollContainer;
        public var scoreCanvas:Panel;

        protected function initializeHandler(event:Event):void
        {
            // No header please.         
            headerFactory = headerFactoryImpl;

            // We want to show the header and footers fixed, and then
            // have an expandable region for the score grid that can
            // pan.
            const vLayout = new VerticalLayout();
            vLayout.padding = 2 * dpiScale;
            layout = vLayout;

            // Set scroll policy.
            verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
            clipContent = false;

            // Do the header row.
            addHeaderRow();

            // Add the container for scores.
            const mcgLayout = new MultiColumnGridLayout();
            mcgLayout.columnCount = 5;
            mcgLayout.columnGap = 4 * dpiScale;
            mcgLayout.rowGap = 4 * dpiScale;

            scoreCanvas = new Panel();
            scoreCanvas.headerFactory = headerFactoryImpl;
            scoreCanvas.layout = mcgLayout;
            scoreCanvas.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
            scoreCanvas.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
            scoreCanvas.clipContent = false;
            scoreCanvas.width = DeviceCapabilities.screenPixelWidth - 8 * dpiScale;

            // And its scroller. We have a separate scroller containing the
            // panel to avoid laying it out continuously.
            scoreCanvasContainer = new ScrollContainer();
            scoreCanvasContainer.width = DeviceCapabilities.screenPixelWidth - 4 * dpiScale;
            scoreCanvasContainer.height = DeviceCapabilities.screenPixelHeight - 104 * dpiScale;
            scoreCanvasContainer.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
            scoreCanvasContainer.clipContent = true;
            scoreCanvasContainer.addChild(scoreCanvas);
            addChild(scoreCanvasContainer);

            // Add a new round button to the score scroller.
            var newRoundButton = new Button();
            var mcgld = new MultiColumnGridLayoutData();
            mcgld.span = 5;
            newRoundButton.layoutData = mcgld;
            newRoundButton.label = "Add Round";
            newRoundButton.addEventListener(Event.TRIGGERED, function() {
                addRowOfScores();
            });
            scoreCanvas.addChild(newRoundButton);

            // And the total row.
            addTotalRow();

            // Add first rounds.
            for(var i=0; i<4; i++)
                addRowOfScores();
        }

        public function addHeaderRow()
        {
            const mcgLayout = new MultiColumnGridLayout();
            mcgLayout.columnCount = 5;
            mcgLayout.columnGap = 8 * dpiScale;
            mcgLayout.rowGap = 8 * dpiScale;

            var container = new ScrollContainer();
            container.layout = mcgLayout;
            container.height = 32 * dpiScale;
            container.width = DeviceCapabilities.screenPixelWidth;
            container.clipContent = false;
            container.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
            container.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;

            var roundLabel = new Label();
            roundLabel.text = " ";
            roundLabel.layoutData = new MultiColumnGridLayoutData();
            container.addChild(roundLabel);

            var player1Label = new Label();
            player1Label.text = "K";
            player1Label.textRendererProperties = { "align":"center" };
            player1Label.layoutData = new MultiColumnGridLayoutData();
            container.addChild(player1Label);

            var player2Label = new Label();
            player2Label.text = "B";
            player2Label.textRendererProperties = { "align":"center" };
            player2Label.layoutData = new MultiColumnGridLayoutData();
            container.addChild(player2Label);

            var player3Label = new Label();
            player3Label.text = "J";
            player3Label.textRendererProperties = { "align":"center" };
            player3Label.layoutData = new MultiColumnGridLayoutData();
            container.addChild(player3Label);

            var player4Label = new Label();
            player4Label.text = "J2";
            player4Label.textRendererProperties = { "align":"center" };
            player4Label.layoutData = new MultiColumnGridLayoutData();
            container.addChild(player4Label);

            addChild(container);
        }

        public function addRowOfScores()
        {
            // Add a row of inputs.
            var startIndex = Math.max(scoreCanvas.numChildren - 1, 0);

            // First generate the row number.
            var row1Label = new Label();
            row1Label.height = 32 * dpiScale;
            
            var labelProps = row1Label.textRendererProperties;
            labelProps["align"] = "center";
            labelProps["vAlign"] = "center";
            row1Label.textRendererProperties = labelProps;

            row1Label.text = rowCount.toString();
            rowCount++;
            row1Label.layoutData = new MultiColumnGridLayoutData();
            scoreCanvas.addChildAt(row1Label, startIndex);

            // And add the column text boxes.
            for(var i=0; i<scoreColumnCount; i++)
            {
                var scoreBox = new TextInput();
                scoreBox.maxChars = 3;
                scoreBox.prompt = "?";
                scoreBox.keyboardType = LoomKeyboardType.NumberPad;
                scoreBox.layoutData = new MultiColumnGridLayoutData();

                var inputPromptProps = scoreBox.promptProperties;
                inputPromptProps["align"] = "center";
                inputPromptProps["vAlign"] = "center";
                scoreBox.promptProperties = inputPromptProps;

                var inputEditorProps = scoreBox.textEditorProperties;
                inputEditorProps["align"] = "center";
                inputEditorProps["vAlign"] = "center";
                scoreBox.textEditorProperties = inputEditorProps;

                scoreBox.addEventListener("change", onScoreChange);
                scoreCanvas.addChildAt(scoreBox, startIndex+1+i);

                scoreBoxes.push(scoreBox);
            }
        }

        public function addTotalRow()
        {
            var container = new ScrollContainer();
            const mcgLayout = new MultiColumnGridLayout();
            mcgLayout.columnCount = 5;
            mcgLayout.columnGap = 8 * dpiScale;
            mcgLayout.rowGap = 8 * dpiScale;

            container.layout = mcgLayout;
            container.height = 72 * dpiScale;
            container.width = DeviceCapabilities.screenPixelWidth;
            container.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
            container.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
            container.clipContent = false;

            var totalLabel = new Label();
            totalLabel.text = "Total";
            totalLabel.textRendererProperties = { "align":"center" };
            totalLabel.layoutData = new MultiColumnGridLayoutData();
            container.addChild(totalLabel);

            totalLabels.length = 0;
            for(var i=0; i<scoreColumnCount; i++)
            {
                var scoreLabel = new Label();
                scoreLabel.layoutData = new MultiColumnGridLayoutData();
                scoreLabel.text = "?";
                scoreLabel.textRendererProperties = { "align":"center" };
                container.addChild(scoreLabel);

                totalLabels.push(scoreLabel);
            }

            var rankCaption = new Label();
            rankCaption.text = "Rank";
            rankCaption.layoutData = new MultiColumnGridLayoutData();
            rankCaption.textRendererProperties = { "align":"center" };

            container.addChild(rankCaption);

            rankLabels.length = 0;
            for(i=0; i<scoreColumnCount; i++)
            {
                var rankLabel = new Label();
                rankLabel.layoutData = new MultiColumnGridLayoutData();
                rankLabel.text = "?";
                rankLabel.textRendererProperties = { "align":"center" };
                container.addChild(rankLabel);

                rankLabels.push(rankLabel);
            }

            addChild(container);
        }

        protected function onScoreChange(e:Event):void
        {
            // Recalculate the totals.
            updateTotals();
        }

        protected function updateTotals():void
        {
            // Calculate the point totals.
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