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
  $form['server_settings']['site_default_country']['#default_value'] = 'United States';
  // Set default timezone
  $form['server_settings']['date_default_timezone']['#default_value'] = 'America/Denver';
}

/**
 * Implements hook_install_tasks().
 */
function bedrock_install_tasks($install_state) {
  $tasks = array(
    'install_omega_subtheme' => array(
      'display_name' => st('Omega subtheme'),
      'display'      => TRUE,
      'type'         => 'form',
      'function'     => 'install_omega_subtheme',
    ),
  );
  
  return $tasks;
}

/**
 * Function for install_omega_subtheme task.
 */
function install_omega_subtheme() {
  $omega_loc = drupal_get_path('theme', 'omega');
  $omega_based = array();

  // Check for starterkits
  $omega_root = substr($omega_loc, 0, -6);
  $skx_loc = $omega_root . '/starterkits/omega-xhtml';
  $sk5_loc = $omega_root . '/starterkits/omega-html5';
  $ska_loc = $omega_root . '/starterkits/alpha-xhtml';
  if (!file_exists($skx_loc) && !file_exists($sk5_loc) && !file_exists($ska_loc)) {
    drupal_set_message(t('No Omega Starterkit directories were found.'), 'warning');
  }

  // We need to get all starterkits, but we don't want the base Omega theme (omega.info)
  foreach (list_themes(TRUE) as $theme) {
    if (isset($theme->base_theme) && ($theme->base_theme === 'omega' || $theme->base_theme === 'alpha') && $theme->filename != 'omega.info') {
      $omega_based[$theme->name] = st('@tname (@tsname)', array('@tname' => $theme->info['name'], '@tsname' => str_replace("/{$theme->name}.info", '', $theme->filename)));
    }
  }

  $form = array(
    // General Subtheme settings
    'general_settings' => array(
      '#title'  => t('General settings'),
      '#type'   => 'fieldset',
      '#weight' => 10,
      'sysname' => array(
        '#type'          => 'textfield',
        '#title'         => st('System name'),
        '#description'   => st('The machine-compatible name of the new theme. This name may only consist of lowercase letters plus the underscore character.'),
        '#default_value' => str_replace(' ', '', strtolower(variable_get('site_name', ''))),
        '#required'      => TRUE,
        '#weight'        => 10,
      ),
      'friendly' => array(
        '#type'          => 'textfield',
        '#title'         => st('Human name'),
        '#description'   => st('A human-friendly name for the new theme. This name may contain uppercase letters, spaces, punctuation, etc.'),
        '#default_value' => variable_get('site_name', ''),
        '#required'      => TRUE,
        '#weight'        => 20,
      ),
      'description' => array(
        '#type'          => 'textfield',
        '#title'         => st('Description'),
        '#description'   => st('A short description of this theme.'),
        '#default_value' => st("@sitename's theme", array('@sitename' => variable_get('site_name', ''))),
        '#required'      => TRUE,
        '#weight'        => 30,
      ),
    ),
    'submit' => array(
      '#type'   => 'submit',
      '#value'  => st('Save and Continue'),
      '#weight' => 1000,
    )
  );
  
  $form['#validate'][] = 'bedrock_install_omega_subtheme_validate';
  $form['#submit'][] = 'bedrock_install_omega_subtheme_submit';
  
  return $form;
}

/**
 * Validation handler for install_omega_subtheme function.
 */
function bedrock_install_omega_subtheme_validate(&$form, &$form_state) {
  if (!preg_match('/^[abcdefghijklmnopqrstuvwxyz][abcdefghijklmnopqrstuvwxyz0-9_]*$/', $form_state['values']['sysname'])) {
    // Zen's documentations say that no digits should be used in theme system
    // names, but that restriction seems to be arbitrary - in actuality, digits
    // can be anywhere except first character (because function names will be
    // named with the theme name as a prefix, and function names cannot begin
    // with a digit in PHP). So even though the form element #description says
    // digits can't be used, we're actually going to allow them so long as
    // they're not in the first character. See this issue:
    // http://drupal.org/node/606574
    // As for why the pattern above doesn't use [a-z], see:
    // http://stackoverflow.com/questions/1930487/will-a-z-ever-match-accented-characters-in-preg-pcre
    form_set_error('sysname', t('The <em>System name</em> may only consist of lowercase letters and the underscore character.'));
  }
}

/**
 * Submission handler for install_omega_subtheme function.
 */
function bedrock_install_omega_subtheme_submit(&$form, &$form_state) {
  $info = array(
    'subtheme_name' => $form_state['values']['sysname'],
    'friendly_name' => $form_state['values']['friendly'],
    'subtheme_desc' => $form_state['values']['description'],
    'initial_dir'   => 'sites/all/themes/subtheme',
  );
  
  // Process the $files array.
  if (process_subtheme($info) !== FALSE) {
    drupal_set_message(t('A new subtheme was successfully created. You may now !config_link.', array('!config_link' => l('configure your new theme', 'admin/flush-cache/cache', array('query' => array('destination' => 'admin/appearance/settings/'. $form_state['values']['sysname']))))));
  }

  // Flush the cached theme data so the new subtheme appears in the parent
  // theme list.
  system_rebuild_theme_data();
  
  // Enable custom theme as default...
  theme_enable(array($form_state['values']['sysname']));
  // ...and disable Drupal's default Bartik theme
  theme_disable(array('bartik'));
  variable_set('theme_default', $form_state['values']['sysname']);
  
  // Setup default blocks
  // --- Main page content
  db_update('block')
    ->fields(array(
      'status' => 1,
      'region' => 'content',
      'weight' => 0,
    ))
    ->condition('module', 'system')
    ->condition('delta', 'main')
    ->condition('theme', $form_state['values']['sysname'])
    ->execute();
  // -- Copyright block (from copyright_block.module)
  db_update('block')
    ->fields(array(
      'status' => 1,
      'region' => 'footer_second',
      'weight' => -12,
      'title'  => '<none>',
    ))
    ->condition('module', 'copyright_block')
    ->condition('delta', 'copyright')
    ->condition('theme', $form_state['values']['sysname'])
    ->execute();
  // -- Promote block (from promote.module (custom module))
  db_update('block')
    ->fields(array(
      'status' => 1,
      'region' => 'footer_second',
      'weight' => -11,
      'title'  => '<none>',
    ))
    ->condition('module', 'promote')
    ->condition('delta', 'promote')
    ->condition('theme', $form_state['values']['sysname'])
    ->execute();
}

/**
 * Process the file queue.
 *
 * @param $files
 *   The files to process.
 */
function process_subtheme($info) {
  $subtheme_dir = "sites/default/themes/{$info['subtheme_name']}";
  // Need to rename 'subtheme' directory
  rename('sites/default/themes/subtheme', $subtheme_dir);
  
  // Need to rename the .info file
  rename("$subtheme_dir/YOURTHEME.info", "$subtheme_dir/{$info['subtheme_name']}.info");
  
  // Make customized changes to .info file
  // Open the file, do replacements and save it
  $text = file_get_contents("$subtheme_dir/{$info['subtheme_name']}.info");
  $text = str_replace('[[subtheme-name]]', $info['friendly_name'], $text);
  $text = str_replace('[[subtheme-desc]]', $info['subtheme_desc'], $text);
  file_put_contents("$subtheme_dir/{$info['subtheme_name']}.info", $text);
  
  // Need to rename responsive grid css files...
  rename("$subtheme_dir/css/YOURTHEME-alpha-default-narrow.scss", "$subtheme_dir/css/{$info['subtheme_name']}-alpha-default-narrow.scss");
  rename("$subtheme_dir/css/YOURTHEME-alpha-default-normal.scss", "$subtheme_dir/css/{$info['subtheme_name']}-alpha-default-normal.scss");
  rename("$subtheme_dir/css/YOURTHEME-alpha-default.scss", "$subtheme_dir/css/{$info['subtheme_name']}-alpha-default.scss");
  rename("$subtheme_dir/css/YOURTHEME-alpha-default-wide.scss", "$subtheme_dir/css/{$info['subtheme_name']}-alpha-default-wide.scss");
}