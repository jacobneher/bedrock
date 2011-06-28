<?php
// $Id: standard.profile,v 1.2 2010/07/22 16:16:42 dries Exp $

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
        '#title'         => st('System name'),
        '#description'   => st('The machine-compatible name of the new theme. This name may only consist of lowercase letters plus the underscore character.'),
        '#type'          => 'textfield',
        '#required'      => TRUE,
        '#weight'        => 10,
      ),
      'friendly' => array(
        '#title'         => st('Human name'),
        '#description'   => st('A human-friendly name for the new theme. This name may contain uppercase letters, spaces, punctuation, etc.'),
        '#type'          => 'textfield',
        '#default_value' => variable_get('site_name', ''),
        '#required'      => TRUE,
        '#weight'        => 20,
      ),
      'description' => array(
        '#title'         => st('Description'),
        '#description'   => st('A short description of this theme.'),
        '#type'          => 'textfield',
        '#default_value' => st("@sitename's theme", array('@sitename' => variable_get('site_name', ''))),
        '#required'      => TRUE,
        '#weight'        => 30,
      ),
      'site' => array(
        '#title'         => st('Site directory'),
        '#description'   => st('Which site directory will the new theme to be placed in? If in doubt, select &ldquo;all&rdquo;.'),
        '#type'          => 'select',
        '#options'       => find_omega_sites(),
        '#default_value' => array('default'),
        '#required'      => TRUE,
        '#weight'        => 40,
      ),
      'parent' => array(
        '#title'         => st('Starter theme'),
        '#description'   => st('The parent theme for the new theme. If in doubt, select &ldquo;Omega XHTML Starter Kit&rdquo;.'),
        '#type'          => 'select',
        '#options'       => $omega_based,
        '#default_value' => 'starterkit_omega_html5',
        '#required'      => TRUE,
        '#weight'        => 50,
      ),
    ),
    'additional_settings' => array(
      '#type'  => 'fieldset',
      '#title' => st('Additional settings'),
      '#collapsible' => 1,
//      '#collapsed' => 1,
      '#weight' => 100,
      'stylesheets' => array(
        '#type'        => 'fieldset',
        '#title'       => st('Stylesheets'),
        '#description' => st('You may create new stylesheets that will be included with this theme.'),
        '#collapsible' => 1,
        '#weight'      => 10,
        'additional_sheets' => array(
          '#type'        => 'textfield',
          '#title'       => st('Stylesheet name(s)'),
          '#description' => st('Define new (blank) stylesheets that you would like to include with this theme, separated by a space.'),
          '#weight'      => 10,
        ),
        'include_style_css' => array(
          '#type'          => 'checkbox',
          '#title'         => st('Include styles.css file included with Omega subthemes by default'),
          '#weight'        => 20,
          '#default_value' => 1,
        ),
      ),
      'grid' => array(
        '#type'        => 'fieldset',
        '#title'       => st('Grid'),
        '#collapsible' => 1,
        '#weight'      => 20,
        'responsive_grid' => array(
          '#type'  => 'checkbox',
          '#title' => st('Enable responsive grid layout'),
        ),
      ),
      'miscellaneous' => array(
        '#type'        => 'fieldset',
        '#title'       => st('Miscellaneous'),
        '#collapsible' => 1,
        '#weight'      => 30,
        'enable_theme' => array(
          '#type'          => 'checkbox',
          '#title'         => st('Enable theme and set as default'),
          '#description'   => st('If checked, this theme will be enabled and be set as the default theme for this website.'),
          '#default_value' => 1,
          '#weight'        => 10,
        ),
      ),
    ),
    'submit' => array(
      '#type'   => 'submit',
      '#value'  => st('Save and Continue'),
      '#weight' => 1000,
    )
  );
  
  if (module_exists('less')) {
    $form['additional_settings']['stylesheets']['less'] = array(
      '#type'   => 'fieldset',
      '#title'  => st('LESS CSS Preprocessing'),
      '#weight' => 30,
      'less_preprocessing' => array(
        '#type'          => 'checkbox',
        '#title'         => st('Make all css files in this subtheme LESS CSS compatible'),
        '#default_value' => 1,
      ),
    );
  }
  
  return $form;
}

/**
 * Validation handler for install_omega_subtheme function.
 */
function install_omega_subtheme_validate(&$form, &$form_state) {
  // Check that the system name of the theme is valid
  if ($exists = drupal_get_path('theme', $form_state['values']['sysname'])) {
    form_set_error('sysname', t('A theme with this <em>System name</em> already exists at %exists. Please choose a different one.', array('%exists' => $exists)));
  }
  elseif (!preg_match('/^[abcdefghijklmnopqrstuvwxyz][abcdefghijklmnopqrstuvwxyz0-9_]*$/', $form_state['values']['sysname'])) {
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
  elseif (!preg_match('/^[abcdefghijklmnopqrstuvwxyz0-9_-\s]*$/', $form_state['values']['additional_sheets'])) {
    form_set_error('additional_sheets', t('There is an issue with one or more of the custom css filenames entered.'));
  }
  elseif (count(form_get_errors()) === 0) {
    // We only want to continue if all required form elements were filled out -
    // http://drupal.org/node/631002
    // Test if we can make these directories. It's pretty dumb to be actually
    // modifying the disk in a validate hook, but I don't know of any better way
    // to test if a directory can be made than going ahead and trying to make
    // it, and I think crashing out with an error in the submit hook is worse,
    // because it won't take the user back to the form with the previous values
    // already filled in, among other reasons.
    $site_dir = 'sites/' . $form_state['values']['site'];
    $themes_dir = $site_dir . '/themes';
    if (!file_exists($themes_dir) && !@mkdir($themes_dir, 0755)) {
      form_set_error('site', t('The <em>themes</em> directory for the %site site directory does not exist, and it could not be created automatically. This is likely a permissions problem. Check that the web server has permissions to write to the %site directory, or create the %themes directory manually and try again.', array('%site' => $site_dir, '%themes' => $themes_dir)), 'error');
    }
    else {
      $dir = "{$themes_dir}/{$form_state['values']['sysname']}";
      if (file_exists($dir)) {
        form_set_error('sysname', t('That <em>System name</em> value cannot be used with that <em>Site directory</em> value. Omegaphile wants to create and use the directory %dir, but a file or directory with that name already exists.', array('%dir' => $dir)));
      }
      else {
        if (!@mkdir($dir)) {
          form_set_error('sysname', t('The directory %dir could not be created. This is likely a permissions problem. Check that the web server has permissions to write to the %themes directory.', array('%dir' => $dir, '%themes' => $themes_dir)));
        }
      }
    }
  }
}

/**
 * Submission handler for install_omega_subtheme function.
 */
function install_omega_subtheme_submit(&$form, &$form_state) {
  $omega_dir = drupal_get_path('theme', 'omega');
  $info = array(
    't_name'      => $form_state['values']['sysname'],
    't_dir'       => "sites/{$form_state['values']['site']}/themes/{$form_state['values']['sysname']}",
    'parent'      => $form_state['values']['parent'],
    'parent_dir'  => drupal_get_path('theme', $form_state['values']['parent']),
    'omega_dir'   => $omega_dir,
    'form_values' => $form_state['values'],
  );

  $cur_path = '';
  $file_list = populate_omega_files($info['parent_dir'], $cur_path);

  $files = array();
  $weight = -10;
  foreach ($file_list as $file => $type) {
    $files[$file] = array(
      'from'   => "{$info['parent_dir']}/{$file}",
      'type'   => $type,
      'repl'   => array(),
      'weight' => $weight += 10,
    );
  }
  
  // Call alter hooks.
  // We can't do module_invoke_all() because it doesn't pass $files by reference
  // to the hook implementations. We'll do it manually. (Thanks, catch in
  // #drupal!)
  foreach (module_implements('subtheme_alter') as $module) {
    $function = $module . '_subtheme_alter';
    if ($function($files, $info) === FALSE) {
      // One of the hook implementations wants to stop everything. It should
      // have shown an error with drupal_set_message. Return without processing
      // any files.
      return;
    }
  }
  // Process the $files array.
  if (process_subtheme($files, $info['t_dir']) !== FALSE) {
    drupal_set_message(t('A new subtheme was successfully created in %dir. You may now !config_link.', array('%dir' => $info['t_dir'], '!config_link' => l('configure your new theme', 'admin/flush-cache/cache', array('query' => array('destination' => 'admin/appearance/settings/'. $form_state['values']['sysname']))))));
  }

  // Flush the cached theme data so the new subtheme appears in the parent
  // theme list.
  system_rebuild_theme_data();

  if ($form_state['values']['enable_theme']) {
    theme_enable(array($form_state['values']['sysname']));
    theme_disable(array('bartik'));
    variable_set('theme_default', $form_state['values']['sysname']);
  }
  
  // Set the 'Main Page Content' block to the content region
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
}


/**
 * List this Drupal installation's site directories.
 *
 * @return
 *   An array of directories in the sites directory.
 */
function find_omega_sites() {
  $sites = array();
  if ($h = opendir('sites')) {
    while (($site = readdir($h)) !== FALSE) {
      $sitepath = 'sites/' . $site;
      // Don't allow dot files or links for security reasons (redundancy, too)
      if (is_dir($sitepath) && !is_link($sitepath) && $site{0} !== '.') {
        $sites[] = $site;
      }
    }
    closedir($h);
    return drupal_map_assoc($sites);
  }
  else {
    drupal_set_message(t('The <em>sites</em> directory could not be read.'), 'error');
    return array();
  }
}

/**
 * Recursively create a list of files in a directory.
 *
 * @param $dir
 *   Directory to add files from
 * @param $cur_path
 *   Path to start from
 * @return
 *   An array of file names.
 */
function populate_omega_files($dir, $cur_path) {
  $files = array();
  if ($cur_path !== '') {
    $cur_path .= '/';
  }
  $h = opendir("{$dir}/{$cur_path}");
  while (($file = readdir($h)) !== FALSE) {
    // Don't copy hidden files
    if ($file{0} !== '.') {
      if (is_dir("{$dir}/{$cur_path}{$file}")) {
        $files["{$cur_path}{$file}"] = 'dir';
        $files = array_merge($files, populate_omega_files($dir, "{$cur_path}{$file}"));
      }
      else {
        $files["{$cur_path}{$file}"] = 'file';
      }
    }
  }
  return $files;
}

/**
 * Process the file queue.
 *
 * @param $files
 *   The files to process.
 */
function process_subtheme($files, $t_dir) {
  // Reorder the queue according to weight
  $weights = array();
  foreach ($files as $file) {
    $weights[] = $file['weight'];
  }
  array_multisort($weights, SORT_ASC, $files);

  foreach ($files as $file => $opts) {
    $dest = "{$t_dir}/{$file}";
    // If there's no "from", create a blank file/dir.
    if ($opts['type'] === 'dir') {
      // We can't copy directories, so don't bother checking the 'from' value.
      // Just make an empty directory.
      mkdir($dest, 0755);
    }
    elseif ($opts['type'] === 'file') {
      if ($opts['from'] === '') {
        // No 'from' value, so just make a blank file
        touch($dest);
      }
      else {
        // If the file is probably not a text, code or CSS file…
        if (!preg_match('/\.(php|css|js|info|inc|html?|te?xt)$/', $file)) {
          // Simply copy the file. Don't do replacements.
          copy($opts['from'], $dest);
        }
        else {
          // Open the file, do replacements and save it
          $text = file_get_contents($opts['from']);
          $text = preg_replace(array_keys($opts['repl']), array_values($opts['repl']), $text);
          // Avoid file_put_contents() for PHP 4 l4mz0rz
          $h = fopen($dest, 'w');
          fwrite($h, $text);
          fclose($h);
        }
      }
    }
  }
}

/**
 * Sets replacement patterns to change the associated theme files.
 *
 * @param $files
 *   The files to process.
 *   
 * @param $info
 *   The information about the theme to create
 * 
 */
function bedrock_subtheme_alter(&$files, $info) {
  $weight = 59990;
  // Rename the .info file, and replace instances of the parent name with
  // that of the child name. Also, add the name and description.
  $dotinfo = $info['t_name'] . '.info';
  $files[$dotinfo] = $files[$info['parent'] . '.info'];
  $files[$dotinfo]['repl'] = array();
  $files[$dotinfo]['repl']["/{$info['parent']}/"] = $info['t_name'];
  $files[$dotinfo]['repl']['/^name\s*=.*/m'] = 'name = ' . $info['form_values']['friendly'];
  $files[$dotinfo]['repl']['/^description\s*=.*/m'] = 'description = ' . $info['form_values']['description'];
  $files[$dotinfo]['repl']['/\n; IMPORTANT: DELETE THESE TWO LINES IN YOUR SUBTHEME\n\nhidden = TRUE\nstarterkit = TRUE\n/'] = '';
  // Remove packaging robot stuff
  $files[$dotinfo]['repl']['/^; Information added by drupal\.org packaging script on .+$/m'] = '';
  $files[$dotinfo]['repl']['/^(version|core|project|datestamp) = ".+$/m'] = '';

  // Determine if LESS CSS styling has been selected
  if ($info['form_values']['less_preprocessing']) {
    foreach (array_keys($files) as $file) {
      if (strpos($file, '.css')) {
        $files[$file . '.less'] = $files[$file];
        unset($files[$file]);
      }
    }
    
    // Putting [ ] around regex pattern so that the pattern doesn't "leak" to other stylesheets
    // that we don't want to change, e.g. alpha-mobile.css
    $files[$dotinfo]['repl']["/(\[|\')styles\.css(\]|\')/"] = '${1}styles.css.less${2}';
    $files[$dotinfo]['repl']["/(\[|\')mobile\.css(\]|\')/"] = '${1}mobile.css.less${2}';
  }
  
  // Additional Stylesheets
  if ($info['form_values']['additional_sheets']) {
    $sheets = explode(' ', $info['form_values']['additional_sheets']);
    $add_stylesheets = "; ------- Stylesheets created with installation profile\n";
    $stylesheet_settings = '';
    $custom_css_weight = 20;
    foreach ($sheets as $sheet) {
      $stylesheet = $sheet . '.css' . ($info['form_values']['less_preprocessing'] ? '.less' : '');
      
      $files["css/$stylesheet"] = array(
        'from' => '', // Left empty since we are creating the file
        'type' => 'file',
        'repl' => '',
        'weight' => 300, // This has to be set higher than the base 'css' folder creation, which is set at 250
      );
      
      // Provide a nicer name for the theme settings page
      $stylesheet_parts = explode('.', $stylesheet);
      $stylesheet_name = ucwords(str_replace(array('-', '_'), ' ', $stylesheet_parts[0]));
      
      $add_stylesheets .= "css[$stylesheet][name] = $stylesheet_name Styles\ncss[$stylesheet][description] = Declared in installation profile.\ncss[$stylesheet][options][weight] = $custom_css_weight\n\n";
      
      $stylesheet_settings .= "\nsettings[alpha_css][$stylesheet] = '$stylesheet'";
      
      $custom_css_weight++;
    }
    
    
    $files[$dotinfo]['repl']["/; THEME SETTINGS \(DEFAULTS\)\n/"] = $add_stylesheets . "; THEME SETTINGS (DEFAULTS)\n";
    if ($info['form_values']['less_preprocessing']) {
      $files[$dotinfo]['repl']["/settings\[alpha_css\]\[mobile\.css\.less\] = 'mobile\.css\.less'/"] = "settings[alpha_css][mobile.css.less] = 'mobile.css.less'" . $stylesheet_settings;
    }
    else {
      $files[$dotinfo]['repl']["/settings\[alpha_css\]\[mobile\.css\] = 'mobile\.css'/"] = "settings[alpha_css][mobile.css] = 'mobile.css'" . $stylesheet_settings;
    }
  }
  
  // Renaming the css files
  foreach (array_keys($files) as $file) {
    if (strpos($file, '.css') && strpos($file, 'alpha-')) {
      $files[preg_replace('/(alpha|starterkit-omega)-(xhtml|html5)/', $info['t_name'], $file)] = $files[$file];
      unset($files[$file]);
    }
  }
  
  // Responsive grid settings
  if (!$info['form_values']['responsive_grid']) {
    $files[$dotinfo]['repl']["/settings\[alpha_responsive\] = '1'/"] = "settings[alpha_responsive] = '0'";
  }

  unset($files[$info['parent'] . '.info']);

  // Copy template.php and theme-settings.php and replace the parent theme's
  // name. The files should already be there in $files, so we'll just tweak their repl arrays.
  $files['template.php']['repl']["/{$info['parent']}/"] = $info['t_name'];
  $files['theme-settings.php']['repl']["/{$info['parent']}/"] = $info['t_name'];
}