<?php
// $Id: standard.profile,v 1.2 2010/07/22 16:16:42 dries Exp $

/**
 * Implements hook_form_FORM_ID_alter().
 *
 * Allows the profile to alter the site configuration form.
 */
function default_form_install_configure_form_alter(&$form, $form_state) {
  $chunks = explode('.', $_SERVER['SERVER_NAME']);
  if (count($chunks) == 3) {
    $domain = $chunks[0];
  }
  else {
    $splitter = explode('?', $_SERVER['REQUEST_URI']);
    $chunks = explode('/', $splitter[0]);
    $domain = $chunks[1];
  }
  $form['site_information']['site_mail']['#default_value'] = 'noreply@' . $domain . '.com';
  
  // Set admin username
  $form['admin_account']['account']['name']['#default_value'] = 'admin';
  // Set admin email
  $form['admin_account']['account']['mail']['#default_value'] = 'jneher@itcoloradosprings.com';
  // Set admin password
  //-- We have to set the type to textfield so that we can enter a default value
  $form['admin_account']['account']['pass']['#type'] = 'textfield';
  $form['admin_account']['account']['pass']['#title'] = 'Password';
  $form['admin_account']['account']['pass']['#default_value'] = 'Jd4ms!';
 
  // Set default country
  $form['server_settings']['site_default_country']['#default_value'] = 'United States';
  // Set default timezone
  $form['server_settings']['date_default_timezone']['#default_value'] = 'America/Denver';
//print '<pre>'; print_r($form); die('</pre>');
}
