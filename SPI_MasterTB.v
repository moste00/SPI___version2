module SPI_MasterTB ;
localparam sizeOfData = 8   ; 
localparam PeriodicTime = 10 ;

reg  load ;
reg [sizeOfData-1:0]data_write ;
reg [1:0]slave_address ;
reg cpol ;
reg cpha ;
reg MISO ;
wire SCLK ;
wire CS1 ;
wire CS2 ;
wire CS3 ;
wire MOSI ;
wire slave_start ;
wire [sizeOfData-1:0]data_read ;

SPI_Master#(sizeOfData , PeriodicTime/2) 

            uut( .load(load) , .data_write(data_write) , .slave_address(slave_address) ,
                .cpol(cpol) , .cpha(cpha) , .MISO(MISO) ,

                .SCLK(SCLK) , .CS1(CS1) , .CS2(CS2) , .CS3(CS3),
                .MOSI(MOSI) , .data_read(data_read) , .slave_start(slave_start)
            );

//the buffer that feeds MISO line, by the end of the communication session should be read into data_read
reg [sizeOfData-1:0]MISO_Stream ;

//loop iterator
integer iterator ;

initial 
begin
   testMode0() ;

   testMode2() ;

   testMode1() ;
 
   testMode3() ;
end

task testMode0() ;
begin
    $display("Now testing mode 0 : reading on rising edge , writing on falling edge") ;
    load = 1 ;
    {cpol,cpha} = 0 ;
    data_write = 'ha5 ; 
    MISO_Stream = 'hba ;
    slave_address = 0 ;
    #(PeriodicTime/2)

    load = 0 ;
    for(iterator = 0; iterator < sizeOfData ; iterator = iterator + 1)
    begin
        MISO = MISO_Stream[iterator];
 	#PeriodicTime ;
    end
    

end
endtask

task testMode2(); 
begin
    $display("Now testing mode 2 : just like mode 0 but with a skipped falling edge in the beginning");
    load = 1 ;
    {cpol,cpha} = 2 ;
    data_write = 'ha5 ; 
    MISO_Stream = 'hba ;
    slave_address = 1 ;
    #(PeriodicTime/2)

    load = 0 ;
    #(PeriodicTime/2) ; //to skip the first falling edge
    for(iterator = 0; iterator < sizeOfData ; iterator = iterator + 1)
    begin
        MISO = MISO_Stream[iterator];
 	#PeriodicTime ;
    end

end
endtask

task testMode1();
begin
    $display("Now testing mode 1 : writing on rising edge , reading on falling edge"); 
    load = 1 ;
    {cpol,cpha} = 1 ;
    data_write = 'ha5 ; 
    MISO_Stream = 'hba ;
    slave_address = 2 ; 
    #(PeriodicTime/2)

    load = 0 ;
    for(iterator = 0; iterator < sizeOfData ; iterator = iterator + 1)
    begin
	#(PeriodicTime/2)  ;
        MISO = MISO_Stream[iterator];
 	#(PeriodicTime/2) ;
    end
end
endtask






task testMode3();
begin

    $display("Now testing mode 3 : just like mode 1 but with a skipped falling edge in the beginning") ;
    load = 1 ;
    {cpol,cpha} = 3;
    data_write = 'ha5 ; 
    MISO_Stream = 'hba ;
    slave_address = 3 ;
    #(PeriodicTime/2)

    load = 0 ;
    #(PeriodicTime/2) ; //to skip the first falling edge
    for(iterator = 0; iterator < sizeOfData ; iterator = iterator + 1)
    begin
	#(PeriodicTime/2);
        MISO = MISO_Stream[iterator];
 	#(PeriodicTime/2) ;
    end
end
endtask

endmodule 