# faq-portlet/tcl/faq-portlet-procs.tcl

ad_library {

Procedures to support the file-storage portlet

Copyright Openforce, Inc.
Licensed under GNU GPL v2 

@creation-date September 30 2001
@author arjun@openforce.net 
@cvs-id $Id$

}

namespace eval faq_portlet {

    ad_proc -private my_name {
    } {
    return "faq-portlet"
    }

    ad_proc -public get_pretty_name {
    } {
	return "Frequently Asked Questions"
    }

    ad_proc -public add_self_to_page { 
	page_id 
	package_id
    } {
	Adds a faq PE to the given page with the package_id
	being opaque data in the portal configuration.
    
	@return element_id The new element's id
	@param page_id The page to add self to
	@param package_id the id of the faq package for this community
	@author arjun@openforce.net
	@creation-date Sept 2001
    } {
	# Tell portal to add this element to the page
	set element_id [portal::add_element $page_id [my_name]]
	
	# The default param "package_id" must be configured
	set key "package_id"
	portal::set_element_param $element_id $key $package_id

	return $element_id
    }

    ad_proc -public show { 
	 cf 
    } {
	 Display the PE
    
	 @return HTML string
	 @param cf A config array
	 @author arjun@openforce.net
	 @creation-date Sept 2001
    } {

	array set config $cf	

	# things we need in the config: package_id

	ns_log notice "AKS55 got here"

	# a big-time query from file-storage
	set query " select faq_id, faq_name
	from acs_objects o, faqs f
	where object_id = faq_id
        and context_id = $config(package_id)
	order by faq_name"
	
	set data ""
	set rowcount 0

	db_foreach select_files_and_folders $query {
	    append data "<tr><td>$faq_id</td><td>$faq_name</td></tr>"
	    incr rowcount
	} 

	set template "
	<table width=100% border=1 cellpadding=2 cellspacing=2>
	<tr>
	<td bgcolor=#cccccc>faq_id</td>
	<td bgcolor=#cccccc>Name</td>
	</tr>
	$data
	</table>"

	ns_log notice "AKS56 got here $rowcount"

	if {!$rowcount} {
	    set template "<i>No faqs available</i><P><a href=faq>more...</a>"
	}

	set code [template::adp_compile -string $template]

	set output [template::adp_eval code]
	ns_log notice "AKS57 got here $output"
	
	return $output

    }

    ad_proc -public remove_self_from_page { 
	portal_id 
	package_id 
    } {
	  Removes a faq PE from the given page 
    
	  @param page_id The page to remove self from
	  @param package_id
	  @author arjun@openforce.net
	  @creation-date Sept 2001
    } {
	# get the element IDs (could be more than one!)
	set element_ids [portal::get_element_ids_by_ds $portal_id [my_name]]

	# remove all elements
	db_transaction {
	    foreach element_id $element_ids {
		portal::remove_element $element_id
	    }
	}
    }
}

 

