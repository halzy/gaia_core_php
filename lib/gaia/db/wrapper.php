<?php

namespace Gaia\DB;

class Wrapper implements IFace {
    
    protected $core;
    
    public function __construct( Iface $core ){
        $this->core = $core;
    }
    
    public function begin(){
        return $this->core->begin();
    }
    
    public function rollback(){
        return $this->core->rollback();
    }
    
    public function commit(){
        return $this->core->commit();
    }
    
    public function execute($query){
        $args = func_get_args();
        return call_user_func_array( array($this->core, 'execute'), $args );
    }
    
    public function format_query($query){
        return $this->core->format_query( $query );
    }
    
    public function format_query_args( $query, array $args ){
        return $this->core->format_query_args( $query, $args );
    }
    
    public function __get( $k ){
        return $this->core->$k;
    }
    
    public function __set( $k, $v ){
        return $this->core->$k = $v;
    }
    
    public function __isset( $k ){
        return isset( $this->core->$k );
    }
    
    public function __call( $method, $args ){
        return call_user_func_array( array( $this->core, $method ), $args );
    }

}