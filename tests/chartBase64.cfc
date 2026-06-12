/**
* cfchart extension tests
*
* Covers chart generation, output formats, chart types, and key attributes.
* Visual appearance is not asserted; tests validate error-free rendering and
* output structure (signatures, dimensions where meaningful).
*/
component extends="org.lucee.cfml.test.LuceeTestCase" labels="chart" {

	private function getSampleData() {
		return [
			{ item: "Apples",  value: 50 },
			{ item: "Oranges", value: 75 },
			{ item: "Pears",   value: 30 }
		];
	}

	private function renderChart( required string type, struct attrs={} ) {
		var format      = structKeyExists( arguments.attrs, "format" ) ? arguments.attrs.format : "png";
		var chartWidth  = structKeyExists( arguments.attrs, "chartWidth" ) ? arguments.attrs.chartWidth : 200;
		var chartHeight = structKeyExists( arguments.attrs, "chartHeight" ) ? arguments.attrs.chartHeight : 150;
		var showtooltip = structKeyExists( arguments.attrs, "showtooltip" ) ? arguments.attrs.showtooltip : false;
		var hasBorder   = structKeyExists( arguments.attrs, "showBorder" );
		var has3D       = structKeyExists( arguments.attrs, "show3D" );

		if ( hasBorder && has3D ) {
			cfchart( format=format, chartWidth=chartWidth, chartHeight=chartHeight, showtooltip=showtooltip, name="local.chartResult", showBorder=arguments.attrs.showBorder, show3D=arguments.attrs.show3D ) {
				cfchartseries( type=arguments.type ) {
					for ( var point in getSampleData() ) {
						cfchartdata( item=point.item, value=point.value );
					}
				}
			};
		} else if ( hasBorder ) {
			cfchart( format=format, chartWidth=chartWidth, chartHeight=chartHeight, showtooltip=showtooltip, name="local.chartResult", showBorder=arguments.attrs.showBorder ) {
				cfchartseries( type=arguments.type ) {
					for ( var point in getSampleData() ) {
						cfchartdata( item=point.item, value=point.value );
					}
				}
			};
		} else if ( has3D ) {
			cfchart( format=format, chartWidth=chartWidth, chartHeight=chartHeight, showtooltip=showtooltip, name="local.chartResult", show3D=arguments.attrs.show3D ) {
				cfchartseries( type=arguments.type ) {
					for ( var point in getSampleData() ) {
						cfchartdata( item=point.item, value=point.value );
					}
				}
			};
		} else {
			cfchart( format=format, chartWidth=chartWidth, chartHeight=chartHeight, showtooltip=showtooltip, name="local.chartResult" ) {
				cfchartseries( type=arguments.type ) {
					for ( var point in getSampleData() ) {
						cfchartdata( item=point.item, value=point.value );
					}
				}
			};
		}

		return local.chartResult;
	}

	private function assertPngBinary( required any data ) {
		expect( isBinary( arguments.data ) ).toBeTrue();
		expect( len( arguments.data ) ).toBeGT( 0 );

		var hex = binaryEncode( arguments.data, "hex" );
		expect( left( hex, 16 ) ).toBe( "89504E470D0A1A0A" );
	}

	private function assertPngBase64( required string data ) {
		expect( len( arguments.data ) ).toBeGT( 0 );
		expect( left( arguments.data, 11 ) ).toBe( "iVBORw0KGgo" );
		assertPngBinary( toBinary( arguments.data ) );
	}

	private function getImageSize( required any data ) {
		var bytes = isBinary( arguments.data ) ? arguments.data : toBinary( arguments.data );
		var bis = createObject( "java", "java.io.ByteArrayInputStream" ).init( bytes );
		var img = createObject( "java", "javax.imageio.ImageIO" ).read( bis );
		bis.close();
		return {
			width  : img.getWidth(),
			height : img.getHeight()
		};
	}

	function run( testResults , testBox ) {

		describe( "base64 rendering", function(){

			it( "base64 as data url", function(){
				savecontent variable="local.chartOutput" {
					cfchart( format="png", chartWidth=300, chartHeight=200, base64=true, showtooltip=false ) {
						cfchartseries( type="bar" ) {
							cfchartdata( item="Apples", value=50 );
							cfchartdata( item="Oranges", value=75 );
						};
					};
				};
				expect( local.chartOutput ).toInclude( "data:image/png;base64" );
			});

			it( "base64 as name", function(){
				cfchart( format="png", chartWidth=300, chartHeight=200, base64=true, name="local.chart", showtooltip=false ) {
					cfchartseries( type="bar" ) {
						cfchartdata( item="Apples", value=50 );
						cfchartdata( item="Oranges", value=75 );
					};
				};

				expect( isDefined( "local.chart" ) ).toBeTrue();
				assertPngBase64( local.chart );
			});

			it( "throws an error when not png", function(){
				expect( function(){
					cfchart( format="jpeg", chartWidth=300, chartHeight=200, base64=true ) {
						cfchartseries( type="bar" ) {
							cfchartdata( item="Apples", value=50 );
							cfchartdata( item="Oranges", value=75 );
						};
					};
				} ).toThrow();
			});

		});

		describe( "chart types", function(){

			var supportedTypes = [ "bar", "line", "curve", "area", "horizontalbar", "pie", "scatter", "step" ];

			for ( var chartType in supportedTypes ) {
				( function( required string type ) {
					it( "renders #type# chart as valid PNG", function(){
						var result = renderChart( type );
						assertPngBinary( result );
					});
				} )( chartType );
			}

			it( "renders time series chart as valid PNG", function(){
				cfchart( format="png", chartWidth=200, chartHeight=150, showtooltip=false, name="local.chartResult" ) {
					cfchartseries( type="time" ) {
						cfchartdata( item="2024-01-01", value=10 );
						cfchartdata( item="2024-02-01", value=25 );
						cfchartdata( item="2024-03-01", value=18 );
					}
				};
				assertPngBinary( local.chartResult );
			});

			it( "renders multiple bar series as valid PNG", function(){
				cfchart( format="png", chartWidth=200, chartHeight=150, showtooltip=false, showLegend=true, name="local.chartResult" ) {
					cfchartseries( type="bar", seriesLabel="East" ) {
						cfchartdata( item="Q1", value=40 );
						cfchartdata( item="Q2", value=55 );
					}
					cfchartseries( type="bar", seriesLabel="West" ) {
						cfchartdata( item="Q1", value=35 );
						cfchartdata( item="Q2", value=48 );
					}
				};
				assertPngBinary( local.chartResult );
			});

			var unsupportedTypes = [ "cone", "cylinder", "pyramid" ];

			for ( var chartType in unsupportedTypes ) {
				( function( required string type ) {
					it( "throws for unsupported type #type#", function(){
						expect( function(){
							renderChart( type );
						} ).toThrow();
					});
				} )( chartType );
			}

		});

		describe( "output formats", function(){

			it( "renders JPEG output with valid signature", function(){
				var result = renderChart( "bar", { format: "jpeg" } );
				expect( isBinary( result ) ).toBeTrue();
				expect( left( binaryEncode( result, "hex" ), 4 ) ).toBe( "FFD8" );
			});

			it( "renders GIF format output as valid binary", function(){
				var result = renderChart( "bar", { format: "gif" } );
				expect( isBinary( result ) ).toBeTrue();
				expect( len( result ) ).toBeGT( 0 );
				// current implementation encodes GIF requests as PNG
				assertPngBinary( result );
			});

			it( "renders PNG at requested dimensions", function(){
				var result = renderChart( "bar", { chartWidth: 120, chartHeight: 80 } );
				var size = getImageSize( result );
				expect( size.width ).toBe( 120 );
				expect( size.height ).toBe( 80 );
			});

		});

		describe( "showBorder", function(){

			it( "renders with boolean showBorder", function(){
				var result = renderChart( "bar", { showBorder: true, chartWidth: 100, chartHeight: 100 } );
				assertPngBinary( result );

				var size = getImageSize( result );
				expect( size.width ).toBe( 100 );
				expect( size.height ).toBe( 100 );
			});

			it( "renders with custom color showBorder at requested dimensions", function(){
				var result = renderChart( "bar", { showBorder: "##FF0000", chartWidth: 100, chartHeight: 100 } );
				assertPngBinary( result );

				var size = getImageSize( result );
				expect( size.width ).toBe( 100 );
				expect( size.height ).toBe( 100 );
			});

			it( "renders custom color border with base64 output", function(){
				cfchart( format="png", chartWidth=100, chartHeight=100, base64=true, showBorder="##0000FF", showtooltip=false, name="local.chart" ) {
					cfchartseries( type="bar" ) {
						cfchartdata( item="A", value=10 );
						cfchartdata( item="B", value=20 );
					}
				};
				assertPngBase64( local.chart );

				var size = getImageSize( toBinary( local.chart ) );
				expect( size.width ).toBe( 100 );
				expect( size.height ).toBe( 100 );
			});

		});

		describe( "show3D", function(){

			it( "renders 3D bar chart as valid PNG", function(){
				var result = renderChart( "bar", { show3D: true } );
				assertPngBinary( result );
			});

			it( "renders 3D line chart as valid PNG", function(){
				var result = renderChart( "line", { show3D: true } );
				assertPngBinary( result );
			});

			it( "renders 3D pie chart as valid PNG", function(){
				var result = renderChart( "pie", { show3D: true } );
				assertPngBinary( result );
			});

		});

		describe( "validation", function(){

			it( "throws when no cfchartseries is provided", function(){
				expect( function(){
					cfchart( format="png", chartWidth=200, chartHeight=150, showtooltip=false, name="local.chartResult" ) {};
				} ).toThrow();
			});

		});

	}

}
