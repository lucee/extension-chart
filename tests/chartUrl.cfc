/**
* cfchart url attribute tests
*
* Validates the image map links generated for the url attribute.
*/
component extends="org.lucee.cfml.test.LuceeTestCase" labels="chart" {

	private string function renderWithUrl( required string type, required string url ) {
		savecontent variable="local.out" {
			cfchart( format="png", chartWidth=300, chartHeight=200, base64=true, showtooltip=false, url=arguments.url ) {
				cfchartseries( type=arguments.type ) {
					cfchartdata( item="Apples", value=50 );
					cfchartdata( item="Oranges", value=75 );
				};
			};
		};
		return local.out;
	}

	function run( testResults , testBox ) {

		describe( "url attribute", function(){

			for ( var chartType in [ "bar", "pie", "line" ] ) {
				( function( required string type ) {

					it( "appends the default query string to a plain url (#type#)", function(){
						var out = renderWithUrl( type, "detail.cfm" );
						expect( out ).toInclude( "<map" );
						expect( out ).toInclude( "detail.cfm?series=" );
						expect( out ).toInclude( "category=Apples" );
					});

					it( "only substitutes variables when the url has a query string (#type#)", function(){
						var out = renderWithUrl( type, "detail.cfm?item=$ITEMLABEL$" );
						expect( out ).toInclude( "detail.cfm?item=Apples" );
						expect( out ).notToInclude( "series=" );
					});

					it( "does not append a query string to a javascript: url (#type#)", function(){
						var out = renderWithUrl( type, "javascript:showItem('$ITEMLABEL$')" );
						expect( out ).toInclude( "<map" );
						expect( out ).toInclude( 'href="javascript:showItem(' );
						expect( out ).toInclude( "Apples" );
						expect( out ).notToInclude( "?series=" );
					});

				} )( chartType );
			}

		});

	}

}
