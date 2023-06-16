"""Module for sequence of frames and depth images captured by Carla simulator.
These parameters may be different for different simulations."""

import os

def resolve_paths(params):
    # List sequences path (relative to dataset folder)
    # Let's just consider any subfolder is a sequence
    params.sequences = [x for x in os.listdir(params.images_root) if os.path.isdir(os.path.join(params.images_root, x))]
    assert (len(params.sequences) > 0), "There are no valid sequences folder in the dataset root"

    # Set source image directory
    params.images = {s: os.path.join(params.dataset_root, s, 'rgb') for s in params.sequences}

    # Set calibration (Kitti format) directory IF ANY (optional)
    params.calib = {s: None for s in params.sequences}

    # Set depth directory
    params.depth = {s: os.path.join(params.dataset_root, s, 'depth') for s in params.sequences}

    return params

def settings():
    settings = {}

    # Camera intrinsic parameters
    settings["cam_hz"] = 30               # Camera Hz (aka FPS)
    settings["cam_CCD_WH"] = [800, 600]  # Camera CDD Width and Height (pixels)
    settings["cam_CCD_pixsize"] = 4.65    # Camera CDD pixel size (micro meters)
    settings["cam_WH"] = [800, 600]      # Camera image Width and Height (pixels)
    settings["cam_focal"] = 6             # Focal length (mm)
    settings["cam_gain"] = 20             # Camera gain
    settings["cam_f_number"] = 6.0        # F-Number
    settings["cam_focus_plane"] = 6.0     # Focus plane (meter)
    settings["cam_exposure"] = 2          # Camera exposure (ms)

    # Camera extrinsic parameters (right-handed coordinate system)
    settings["cam_pos"] = [1.5, 1.5, 0.3]     # Camera pos (meter)
    settings["cam_lookat"] = [1.5, 1.5, -1.]  # Camera look at vector (meter)
    settings["cam_up"] = [0., 1., 0.]         # Camera up vector (meter)

    # Sequence-wise settings
    settings["sequences"] = {}
    settings["sequences"]["seq1"] = {}
    settings["sequences"]["seq1"]["sim_mode"] = "normal"
    settings["sequences"]["seq1"]["sim_duration"] = 10  # Duration of the rain simulation (sec)

    return settings
