<?php
/**
 * Implements hook_form_FORM_ID_alter().
 *
 * Allows the profile to alter the site configuration form.
 */
function bedrock_form_install_configure_form_alter(&$form, $form_state) {
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
  $form['admin_account']['account']['mail']['#default_value'] = 'services@threeshadowsmedia.com';
  // Set admin password
  //-- We have to set the type to textfield so that we can enter a default value
  $form['admin_account']['account']['pass']['#type'] = 'textfield';
  $form['admin_account']['account']['pass']['#title'] = 'Password';
  $form['admin_account']['account']['pass']['#default_value'] = 'Jd4ms!';
 
  // Set default country
  $form['server_settings']['site_default_country']['#default_value'] = 'US';
  // Set default timezone
  $form['server_settings']['date_default_timezone']['#default_value'] = 'America/Denver';
  
  // Collapse some fieldsets that we have auto-filled all the fields in
  $form['admin_account']['#collapsible'] = 1;
  $form['admin_account']['#collapsed'] = 1;
  $form['server_settings']['#collapsible'] = 1;
  $form['server_settings']['#collapsed'] = 1;
  $form['update_notifications']['#collapsible'] = 1;
  $form['update_notifications']['#collapsed'] = 1;
}

/**
 * Implements hook_install_tasks().
 */
function bedrock_install_tasks($install_state) {
//  $tasks = array(
//  );
  
//  return $tasks;
}