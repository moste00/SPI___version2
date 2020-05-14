module SPI_Master
                 #(parameter sizeOfData = 8 , parameter halfPeriod = 5)

                  ( input load , input [sizeOfData-1:0]data_write ,
                    input [1:0]slave_address , input cpol , input cpha , 
                    input MISO,

                    output reg SCLK , output reg CS1 , output reg CS2 , output reg CS3,
                    output reg MOSI , output reg[sizeOfData-1:0]data_read , output reg slave_start) ;


wire CPOL ;
wire CPHA ;
wire [sizeOfData-1:0]transmission_buffer ;
assign CPOL = (load)? cpol : CPOL ;
assign CPHA = (load)? cpha : CPHA ;
assign transmission_buffer = (load)? data_write : transmission_buffer ;

integer transmission_iterator ;

always @(negedge load)
begin
    transmission_iterator = 0 ;
    data_read = 'bx ;

    //1-) decoding the slave_address into CS buses
    {CS1,CS2,CS3} = 'b111 ;
    case(slave_address)
    0 : CS1 = 0 ;
    1 : CS2 = 0 ;
    2 : CS3 = 0 ;
    endcase 

    //2-) setting up the clock and skipping an edge in the cases where it's required
    SCLK  =  CPOL ;
    if(CPOL) #halfPeriod SCLK = ~SCLK ;

    //3-) communication loop
    slave_start = 1 ;
    while(!load && transmission_iterator < sizeOfData)
    begin
        read_write() ;

        transmission_iterator = transmission_iterator + 1 ;
    end

    slave_start = 0;
end

task read_write() ;
begin

	//CPHA == 1 , write on rising edge , read on falling 
	if(CPHA)
	begin
	        #halfPeriod SCLK = ~SCLK ;
	        MOSI = data_write[transmission_iterator] ;
	        #halfPeriod SCLK = ~SCLK ;
	        data_read[transmission_iterator] = MISO  ;

	end

	//CPHA == 0 , read on rising , write on falling 
	if(!CPHA)
	begin
	        #halfPeriod SCLK = ~SCLK ;
	        data_read[transmission_iterator] = MISO  ;
	        #halfPeriod SCLK = ~SCLK ;
	        MOSI = data_write[transmission_iterator] ;
	end
end
endtask 

endmodule 